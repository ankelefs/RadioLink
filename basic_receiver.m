% Real-time Spectrum Analysis using ADALM-PLUTO

% Setup parameters
 run('params.m');
% Setup PlutoSDR System object for receiving
rx = sdrrx('Pluto');
rx.CenterFrequency = fc;
rx.BasebandSampleRate = fs;
rx.SamplesPerFrame = numSamples;
rx.OutputDataType = 'double';

% Main processing loop
keepRunning = true; % Control variable to keep the loop running
i=0;
while i<4

    rxData = rx();
    %scatterplot(rxData);
    
    
    % Concatenate overlapBuffer with the current samples (rxData)
    currentBuffer = [overlapBuffer; rxData];

    % Filter the received signal. Remove a portion of the signal to account for the filter delay.
    rxSigFiltered = upfirdn(currentBuffer, rrcFilter,1,1);
    %doFFT(rxSigFiltered, M, Fs);
    rxSigFiltered = rxSigFiltered(sps*span+1:end-(span*sps-1)); %Multiply with sps if signal still oversampled



    % Frequency compensation -------------------------------------------
    coarseSync = comm.CoarseFrequencyCompensator( ...  
        'Modulation','QPSK', ...
        'FrequencyResolution',1, ...
        'SampleRate',1e6); %Fs*sps if signal is still oversampled

    [rxSigCoarse, freqEstimate] = coarseSync(rxSigFiltered);


    % Symbol Synchronizer (Timing) --------------------------------------------
    symbolSync = comm.SymbolSynchronizer(...
        'TimingErrorDetector', 'Gardner (non-data-aided)', ...
        'DampingFactor', 0.7, ...
        'NormalizedLoopBandwidth', 0.01, ...
        'SamplesPerSymbol', sps); 

    % Correct timing errors, downsamples by sps
    rxSigSync = symbolSync(rxSigCoarse);

    scatterplot(rxSigFiltered);
    scatterplot(rxSigCoarse);
    scatterplot(rxSigSync);

    %----------------------------FRAME SYNC----------------------------------
    [rxSigFrame, partialPacket, packetComplete,dataStartIdx] = extractPacket(rxSigSync, barkerSequence, M, dataLength, overlapBuffer, partialPacket);
    packetComplete
    %scatterplot(rxSigFrame);
    
    if packetComplete
        % Only proceed with phase correction and further processing if a complete packet was extracted
        scatterplot(rxSigFrame);

        %----------------------------PHASE CORRECTION-------------------
        [rxSigPhaseCorrected, estPhaseShiftDeg] = estimatePhaseOffset(rxSigFrame, barkerSequence, M);
        scatterplot(rxSigPhaseCorrected);

        % Fine frequency sync and FINE phase sync
        fineSync = comm.CarrierSynchronizer('DampingFactor', 0.7, 'NormalizedLoopBandwidth', 0.01, 'SamplesPerSymbol', sps, 'Modulation', 'QPSK');
        rxSigFine = fineSync(rxSigPhaseCorrected);

        % Demodulate
        rxDataDemod = pskdemod(rxSigFine, M, pi/M, 'gray');
        scatterplot(rxDataDemod);
    else
        disp('Incomplete packet received. Waiting for the rest...');
    end

    % Update overlapBuffer with the last part of rxData for the next iteration
    overlapBuffer = rxData(end-overlapSize+1:end);
    i=i+1;
end


% Spectrum analyze
%spectrumAnalyze(rx);
%release(spectrumAnalyzerObj);
% Release the System objects
release(rx);

