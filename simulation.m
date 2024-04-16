% Real-time Spectrum Analysis using ADALM-PLUTO

% Setup parameters
 run('params.m');

 
  % Frequency compensation -------------------------------------------
    coarseSync = comm.CoarseFrequencyCompensator( ...  
        'Modulation','QPSK', ...
        'FrequencyResolution',1000, ...
        'SampleRate',1e6*sps); %Fs*sps if signal is still oversampled, 1e6 when using pluto
   
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
     %   'NumForwardTaps',numFeedforwardTaps, ...
     %   'NumFeedbackTaps',numFeedbackTaps, ...
     %   'StepSize',0.01, ...
     %   'Constellation',pskmod(0:M-1, M, pi/M, 'gray'), ...
     %   'ReferenceTap',1);
    
  
  
    
    
     % Fine frequency sync and FINE phase sync
        fineSync = comm.CarrierSynchronizer('DampingFactor', 0.7, 'NormalizedLoopBandwidth', 0.01, 'SamplesPerSymbol', 1, 'Modulation', 'QPSK');


% Main processing loop
keepRunning = true; % Control variable to keep the loop running
i=0;
while i<1
    
    %scatterplot(txSig);
    rxData = simulateChannelEffects(txSigFiltered, 1e6, 30000, 0, deg2rad(110), 0); %input, fs, snr, freqOffset, phaseOffset, distortion
    %scatterplot(rxData);
    tic
    % Concatenate overlapBuffer with the current samples (rxData)
    currentBuffer = [overlapBuffer; rxData];

    % Filter the received signal. Remove a portion of the signal to account for the filter delay.
    rxSigFiltered = upfirdn(currentBuffer, rrcFilter,1,1);
    %doFFT(rxSigFiltered, M, Fs);
    rxSigFiltered = rxSigFiltered(sps*span+1:end-(span*sps-1)); %Multiply with sps if signal still oversampled

 
    
    % Frequency compensation -------------------------------------------
    [rxSigCoarse, freqEstimate] = coarseSync(rxSigFiltered);
    
    % Correct timing errors, downsamples by sps
    rxSigSync = symbolSync(rxSigCoarse);
    
    % Apply the Decision Feedback Equalizer
    %rxSigEqualized = dfe(rxSigSync,rxSigSync(1:100));

    %scatterplot(rxSigFiltered);
    %scatterplot(rxSigCoarse);
    %scatterplot(rxSigSync);
    %scatterplot(rxSigEqualized);
    

    %----------------------------FRAME SYNC----------------------------------
    [rxSigFrame, partialPacket, packetComplete,dataStartIdx] = extractPacket(rxSigSync, barkerSequence, M, dataLength, overlapBuffer, partialPacket);
    packetComplete;
    %scatterplot(rxSigFrame);
    if packetComplete
        % Only proceed with phase correction and further processing if a complete packet was extracted
        %scatterplot(rxSigFrame);

        %----------------------------PHASE CORRECTION-------------------
        [rxSigPhaseCorrected, estPhaseShiftDeg] = estimatePhaseOffset(rxSigFrame, barkerSequence, M, rxSigSync, dataStartIdx);
        %scatterplot(rxSigPhaseCorrected);

       
        rxSigFine = fineSync(rxSigPhaseCorrected);
        %scatterplot(rxSigFine);
        % Demodulate
        rxDataDemod = pskdemod(rxSigFine, M, pi/M, 'gray');
        
        numErrs = symerr(data, rxDataDemod)
        toc
        
    else
        disp('Incomplete packet received. Waiting for the rest...');
    end

    % Update overlapBuffer with the last part of rxData for the next iteration
    overlapBuffer = rxData(end-overlapSize+1:end);
    i=i+1;
end



