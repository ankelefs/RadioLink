% Real-time Spectrum Analysis using ADALM-PLUTO

% Setup parameters
 run('params.m');
% Setup PlutoSDR System object for receiving
rx = sdrrx('Pluto');
rx.CenterFrequency = fc;
rx.BasebandSampleRate = fs;
rx.SamplesPerFrame = numSamples;
rx.OutputDataType = 'double';
rxData = rx();
%scatterplot(rxData);


% Filter the received signal. Remove a portion of the signal to account for the filter delay.
rxSigFiltered = upfirdn(rxData, rrcFilter,1,1);
%doFFT(rxSigFiltered, M, Fs);
rxSigFiltered = rxSigFiltered(sps*span+1:end-(span*sps-1)); %Multiply with sps if signal still oversampled



% Frequency compensation -------------------------------------------
% Coarse first
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
%----------------------------FRAME SYNC-----------------------------------
% PSK modulate barkerSequence used in transmission
barkerSymbols = pskmod(barkerSequence, M, pi/M, 'gray');
detector = comm.PreambleDetector(barkerSymbols.', 'Threshold', 12);
idx = detector(rxSigSync)
dataStartIdx = idx+1;
rxSigFrame = rxSigSync(dataStartIdx:end);

scatterplot(rxSigFrame);
% Estimate phase offset --------------------------------------------------
% Don't use first sample as it is centered by the timing synchronizer?
receivedPilotSymbols = rxSigSync(dataStartIdx-length(barkerSymbols)+1:dataStartIdx-1);
% Modulate the known pilot sequence and upsample!!!
expectedPilotSymbols = pskmod(barkerSequence(2:end), M, pi/M, 'gray');
phaseDifferences = angle(receivedPilotSymbols.* conj(expectedPilotSymbols.'));

% Estimate the phase shift as the mean of the phase differences
estPhaseShift = mean(phaseDifferences);% Correct phase shift
estPhaseShiftDeg = rad2deg(estPhaseShift)
% Correct for phase shift
rxSigPhase = rxSigFrame * exp(-1i * estPhaseShift);





% Fine frequency sync and FINE phase sync, does not work if phase offset is
% outside of quadrant.
fineSync = comm.CarrierSynchronizer( ...
    'DampingFactor',0.7, ...
    'NormalizedLoopBandwidth',0.01, ...
    'SamplesPerSymbol',sps, ...
    'Modulation','QPSK');
rxSigFine = fineSync(rxSigPhase);



% Demodulate -------------------------------------------------------------
rxDataDemod = pskdemod(rxSigFine , M, pi/M, 'gray');

scatterplot(rxDataDemod);

% Spectrum analyze
%spectrumAnalyze(rx);
%release(spectrumAnalyzerObj);
% Release the System objects
release(rx);

