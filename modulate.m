% Modulate signal M-PSK 
M = 4;

% Model speech as random data
data = randi([0 M-1], 10000, 1);
%data = repmat(3,40000,1);

%Pilot sequence
pilotSequence = repmat([1, 1, 1, 3], 1, 4); % Repeat sequence N times
data = [pilotSequence'; data];              % Concenate with random data

% M-PSK modulate 
txSig = pskmod(data, M, pi/M, 'gray'); % input, modulation order, phase offset, symbol order


% RRC Filter parameters
rolloff = 0.5;  % Roll-off factor
span = 8;      % Filter span in symbols
sps = 4;        % Samples per symbol

% Create RRC Filters
rrcFilter = rcosdesign(rolloff, span, sps);

% Apply rrcFilter to txSig. Upsample by sps
txSigFiltered = upfirdn(txSig, rrcFilter, sps);

% Channel
rxSig = awgn(txSigFiltered, 50);

% Simulate Frequency Offset
Fs = 1e6; 
%frequencyOffset = randi([1000 10000]); % Frequency offset in Hz
frequencyOffset = 10000;
t = (0:length(rxSig)-1)'/(Fs*sps); % Time vector in seconds
rxSig = rxSig .* exp(1i * 2 * pi * frequencyOffset * t); % Apply frequency offset

% Apply a phase shift
phi = 30; % Phase shift of x degrees
rxSig = rxSig * exp(1i * deg2rad(phi));



% Filter and downsample the received signal. Remove a portion of the signal to account for the filter delay.
rxSigFiltered = upfirdn(rxSig, rrcFilter,1,1);
%doFFT(rxSigFiltered, M, Fs);
rxSigFiltered = rxSigFiltered(sps*span+1:end-(span*sps-1)); %Multiply with sps if signal still oversampled


% Frequency compensation -------------------------------------------
% Coarse first
coarseSync = comm.CoarseFrequencyCompensator( ...  
    'Modulation','QPSK', ...
    'FrequencyResolution',1, ...
    'SampleRate',Fs*sps); %Fs*sps if signal is still oversampled

[rxSigCoarse, freqEstimate] = coarseSync(rxSigFiltered);


% Estimate phase offset --------------------------------------------------
receivedPilotSymbols = downsample(rxSigCoarse(1:(length(pilotSequence)*sps)), sps);
% Modulate the known pilot sequence and upsample!!!
expectedPilotSymbols = pskmod(pilotSequence', M, pi/M, 'gray');

phaseDifferences = angle(receivedPilotSymbols .* conj(expectedPilotSymbols));
% Estimate the phase shift as the mean of the phase differences
estimatedPhaseShift = mean(phaseDifferences);
% Correct phase shift
rxSigPhase = rxSigCoarse * exp(-1i * estimatedPhaseShift);
%rad2deg(estimatedPhaseShift)



% Fine frequency sync and FINE phase sync, does not work if phase offset is
% outside of quadrant.
fineSync = comm.CarrierSynchronizer( ...
    'DampingFactor',0.7, ...
    'NormalizedLoopBandwidth',0.01, ...
    'SamplesPerSymbol',sps, ...
    'Modulation','QPSK');
rxSigFine = fineSync(rxSigPhase);


% Symbol Synchronizer (Timing) --------------------------------------------
symbolSync = comm.SymbolSynchronizer(...
    'TimingErrorDetector', 'Gardner (non-data-aided)', ...
    'DampingFactor', 0.7, ...
    'NormalizedLoopBandwidth', 0.01, ...
    'SamplesPerSymbol', sps); 

% Correct timing errors, downsamples by sps
rxSigSync = symbolSync(rxSigFine);


% Demodulate -------------------------------------------------------------
rxData = pskdemod(rxSigSync , M, pi/M, 'gray');

% Error calculation
numErrs = symerr(data, rxData);

% Scatter plots
%scatterplot(txSig);
scatterplot(rxSig);
scatterplot(rxSigFiltered);
scatterplot(rxSigCoarse);
scatterplot(rxSigPhase);
scatterplot(rxSigFine);
scatterplot(rxSigSync);
eyediagram(rxSigSync,3);

%fft
%doFFT(rxSig, M, Fs);





