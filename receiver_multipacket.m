% Real-time Spectrum Analysis using ADALM-PLUTO

% Setup parameters
 run('params.m');
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
        'SampleRate',1e6); %Fs*sps if signal is still oversampled
   
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
while i<10
    
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

        if packetComplete
            % Only proceed with phase correction and further processing if a complete packet was extracted

            %----------------------------PHASE CORRECTION-------------------
            [rxSigPhaseCorrected, estPhaseShiftDeg] = estimatePhaseOffset(rxSigFrame, barkerSequence, M, rxSigSync, dataStartIdx);
            % Fine frequency sync and FINE phase sync
            rxSigFine = fineSync(rxSigPhaseCorrected);

            % Demodulate
            rxDataDemod = pskdemod(rxSigFine, M, pi/M, 'gray');

            % Assuming 'data' is the originally transmitted data you're comparing against, and 'numErrs' is initialized earlier
            numErrs = numErrs + symerr(data, rxDataDemod);

            if packetIdx == length(rxSigFrames) % Check if it's the last packet for this iteration
                disp(['Number of errors for the last packet: ', num2str(numErrs)]);
            end

        else
            disp('Incomplete packet received. Waiting for the rest...');
        end
    end

    % Assuming 'rxData' is the raw data buffer you're processing
    % Update overlapBuffer with the last part of rxData for the next iteration
    % Ensure 'overlapSize' is defined and initialized correctly
    overlapBuffer = rxData(end-overlapSize+1:end);

end


% Spectrum analyze
%spectrumAnalyze(rx);
%release(spectrumAnalyzerObj);
% Release the System objects
release(rx);
