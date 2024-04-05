
% Setup parameters
run('soundParams.m');
load('fasit.mat')
% Setup PlutoSDR System object for receiving
rx = sdrrx('Pluto');
rx.CenterFrequency = fc;
rx.BasebandSampleRate = fs;
rx.SamplesPerFrame = numSamples;
rx.OutputDataType = 'double';

%Define objects
    % Frequency compensation -------------------------------------------
    coarseSync = comm.CoarseFrequencyCompensator( ...  
        'Modulation','QPSK', ...
        'FrequencyResolution',100, ...
        'SampleRate',fs); %Fs*sps if signal is still oversampled
   
   % Symbol Synchronizer (Timing) --------------------------------------------
    symbolSync = comm.SymbolSynchronizer(...
        'TimingErrorDetector', 'Gardner (non-data-aided)', ...
        'DampingFactor', 0.7, ...
        'NormalizedLoopBandwidth', 0.01, ...
        'SamplesPerSymbol', sps); 
   
     % Initialize Decision Feedback Equalizer (DFE)
    %numFeedforwardTaps = 5; % Number of feedforward taps
    %numFeedbackTaps = 3;    % Number of feedback taps
    %dfe = comm.DecisionFeedbackEqualizer('Algorithm','LMS', ...
    %    'NumForwardTaps',numFeedforwardTaps, ...
    %    'NumFeedbackTaps',numFeedbackTaps, ...
    %    'StepSize',0.01, ...
    %    'Constellation',pskmod(0:M-1, M, pi/M, 'gray'), ...
    %    'ReferenceTap',1);
    
  
     % Fine frequency sync and FINE phase sync
     fineSync = comm.CarrierSynchronizer('DampingFactor', 0.7, ...
        'NormalizedLoopBandwidth', 0.01, ...
        'SamplesPerSymbol', 1, ...
        'Modulation', 'QPSK');




% Main processing loop
keepRunning = true; % Control variable to keep the loop running
i=0;
numErrs = 0;
previousPhaseShift = 0;
% Initialize the vector for storing demodulated data
%estimatedTotalSymbols = 1000 * 300;
%allDemodulatedPackets = zeros(estimatedTotalSymbols, 1); % Preallocate with zeros
% Use an index to keep track of where to insert new data
%insertIndex = 1;

pool = gcp('nocreate'); % If no pool, do not create a new one
if isempty(pool)
    pool = parpool; % Create a new pool if none exists
end
player = audioDeviceWriter('SampleRate', fss);
packetsToStore = 20; % Number of packets to store before playback
packetCounter = 0; % Counter to track stored packets
% Initialize the buffer based on the expected size of rxDataDemod
demodBuffer = zeros(dataLength * packetsToStore, 1);
insertIndexDemod = 1; % Start index for inserting data into demodBuffer
while i<200 
    rxData = rx();
    %scatterplot(rxData);
    
    % Concatenate overlapBuffer with the current samples (rxData)
    currentBuffer = [overlapBuffer; rxData];

    % Filter the received signal. Remove a portion of the signal to account for the filter delay.
    rxSigFiltered = upfirdn(currentBuffer, rrcFilter,1,1);
    %doFFT(rxSigFiltered, M, Fs);
    rxSigFiltered = rxSigFiltered(sps*span+1:end-(span*sps-1)); %Multiply with sps if signal still oversampled
    
    % Frequency compensation -------------------------------------------
    [rxSigCoarse, freqEstimate] = coarseSync(rxSigFiltered);


    % Symbol Synchronizer (Timing) --------------------------------------------
    % Correct timing errors, downsamples by sps
    rxSigSync = symbolSync(rxSigCoarse);
    
    
    % Initialize Decision Feedback Equalizer (DFE) 
    % Apply the Decision Feedback Equalizer
    %rxSigEqualized = dfe(rxSigSync,rxSigSync(1:1000));

    %scatterplot(rxSigFiltered);
    %scatterplot(rxSigCoarse);
    %scatterplot(rxSigSync);
    %scatterplot(rxSigEqualized);
    

    %----------------------------FRAME SYNC----------------------------------
    [rxSigFrames, partialPacket, packetCompletes,dataStartIdxs] = extractPackets(rxSigSync, barkerSequence, M, dataLength, overlapBuffer, partialPacket);
    %packetComplete;
    %scatterplot(rxSigFrame);
    % Iterate through each extracted packet
    for packetIdx = 1:length(rxSigFrames) 
        rxSigFrame = rxSigFrames{packetIdx}; % Extracted packet
        packetComplete = packetCompletes(packetIdx); % Completion status of the packet
        dataStartIdx = dataStartIdxs(packetIdx); % Starting index of the packet 
        % PROBLEM: PARTIALPACKET HAR JO IKKE IDX, SAA KAN IKKE ITERERE GJENNOM RXSIGFRAMES
 
        if packetComplete
            % Only proceed with phase correction and further processing if a complete packet was extracted

            %----------------------------PHASE CORRECTION-------------------
            [rxSigPhaseCorrected, estPhaseShift, estPhaseShiftDeg] = estimatePhaseOffset(rxSigFrame, barkerSequence, M, rxSigSync, dataStartIdx);
            % Fine frequency sync and FINE phase sync
            rxSigFine = fineSync(rxSigPhaseCorrected);
            %scatterplot(rxSigPhaseCorrected)
            %scatterplot(rxSigFine);
            % Demodulate
            rxDataDemod = pskdemod(rxSigFine, M, pi/M, 'gray');
            
            %numErrs =  symerr(singlePacket, rxDataDemod)
            % Append demodulated data to the storage vector
            %allDemodulatedPackets(insertIndex:(insertIndex + dataLength - 1)) = rxDataDemod;
            %insertIndex = insertIndex + dataLength; % Update the insertIndex
            % Assuming 'data' is the originally transmitted data you're comparing against, and 'numErrs' is initialized earlier
            %numErrs =  symerr(data, rxDataDemod)
            
            % Calculate the new insert indices for the demodulated data
            startIdx = insertIndexDemod;
            endIdx = insertIndexDemod + dataLength - 1;

            % Update the buffer with the new demodulated data
            demodBuffer(startIdx:endIdx) = rxDataDemod;

            % Update the insert index for the next batch of data
            insertIndexDemod = endIdx + 1;
            packetCounter = packetCounter + 1;

            % Check if the buffer is full (20 packets have been stored)
            if packetCounter == packetsToStore
                % Convert the buffer to audio and play back
                receivedBits = reshape(de2bi(demodBuffer, log2(M), 'left-msb').', 1, []);
                receivedAudio = typecast(uint16(bin2dec(reshape(char(receivedBits + '0'), 16, []).')), 'int16');
                normalizedAudio = double(receivedAudio) / 32767; % Normalize for playback
                
                % Play buffer
                f = parfeval(pool, @playAudioBlock, 0, normalizedAudio, player);
                %player(normalizedAudio);  
                s=1
                % Reset 
                demodBuffer = zeros(dataLength * packetsToStore, 1);
                packetCounter = 0;
                insertIndexDemod = 1;

            end
        end  
    end
    
    
    % Assuming 'rxData' is the raw data buffer you're processing
    % Update overlapBuffer with the last part of rxData for the next iteration
    % Ensure 'overlapSize' is defined and initialized correctly
    overlapBuffer = rxData(end-overlapSize+1:end);
    i = i+1;
end

%scatterplot(rxSigFine);
%eyediagram(rxSigFine,3);

% Play the normalized audio
%sound(normalizedAudio, fss);


% Spectrum analyze
%spectrumAnalyze(rx);
%release(spectrumAnalyzerObj);
% Release the System objects
s=5
release(rx);
function playAudioBlock(audioData,player)
    player(audioData);
end
