
% Setup parameters
run('soundParams.m');
%load('fasit.mat')
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
        'FrequencyResolution',10, ...
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



    % PSK modulate barkerSequence used in transmission
    barkerSymbols = pskmod(barkerSequence, M, pi/M, 'gray');
    detector = comm.PreambleDetector(barkerSymbols.', 'Threshold', 18); 
    
    
% Main processing loop
keepRunning = true;
i=0;
numErrs = 0;
previousPhaseShift = 0;

% AUDIO PLAYBACK
player = audioDeviceWriter('SampleRate',newFs);
packetsToStore = 1; % Number of packets to store before playback
packetCounter = 0; % Counter to track stored packets
% Initialize the buffer based on the expected size of rxDataDemod
demodBuffer = zeros(dataLength * packetsToStore, 1);
insertIndexDemod = 1; % Start index for inserting data into demodBuffer

%Control packet loss
receivedPacketNumbers = [];
while i<40
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
    [rxSigFrames, packetCompletes,dataStartIdxs, packetNumbers] = extractPackets(rxSigSync, detector, dataLength, barkerLength, headerLength);
    % Append received packet numbers
    receivedPacketNumbers = [receivedPacketNumbers packetNumbers];
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

            % Check if the buffer is full 
            if packetCounter == packetsToStore
                
                %16 BIT CONVERTER
                receivedBits = reshape(de2bi(demodBuffer, log2(M), 'left-msb').', 1, []);
                receivedAudio = typecast(uint16(bin2dec(reshape(char(receivedBits + '0'), 16, []).')), 'int16');
                normalizedAudio = (double(receivedAudio)) / 32767; % Normalize for playback
                
                %8 BIT
                %receivedBits = reshape(de2bi(demodBuffer, log2(M), 'left-msb').', 1, []);
                %receivedAudio8Bit = typecast(uint8(bin2dec(reshape(char(receivedBits + '0'), 8, []).')), 'int8');
                %receivedAudio8Bit = uint8(bin2dec(reshape(char(receivedBits + '0'), 8, []).'));
                %normalizedAudio = (double(receivedAudio8Bit) - 128) / 128;

                % Play buffer
                %sound(normalizedAudio, newFs);
                player(normalizedAudio);  

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
packetLoss = checkPacketLoss(receivedPacketNumbers)
%scatterplot(rxData);
%scatterplot(rxSigFiltered);
%scatterplot(rxSigCoarse);
%scatterplot(rxSigSync);
%scatterplot(rxSigPhaseCorrected);
%scatterplot(rxSigFine);

%eyediagram(rxSigSync,3);
%eyediagram(rxSigFine,3);

% Spectrum analyze
%spectrumAnalyze(rx);
%release(spectrumAnalyzerObj);
% Release the System objects
release(rx);

