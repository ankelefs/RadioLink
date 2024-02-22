% Modulate signal M-PSK 
M = 4;

% Model speech as random data
data = randi([0 M-1], 1000000, 1);
%data = repmat(3,10000,1);

% Barker Code sequence
barkerCode = [1, 1, 1, 1, 1, -1, -1, 1, 1, -1, 1, -1, 1]; % Barker code length 13
barkerCodeMapped = (barkerCode + 1)/2; % Mapping [-1, 1] to [0, 1] for QPSK
barkerCodeMapped2 = barkerCodeMapped+2;
barkerSequence = [barkerCodeMapped, barkerCodeMapped2,barkerCodeMapped, barkerCodeMapped2];


packet = [barkerSequence.'; data];         % Concenate with random data

% M-PSK modulate 
txSig = pskmod(packet, M, pi/M, 'gray'); % input, modulation order, phase offset, symbol order


% RRC Filter parameters
rolloff = 0.5;  % Roll-off factor
span = 12;      % Filter span in symbols
sps = 8;        % Samples per symbol

% Create RRC Filters
rrcFilter = rcosdesign(rolloff, span, sps);

% Apply rrcFilter to txSig. Upsample by sps
txSigFiltered = upfirdn(txSig, rrcFilter, sps);
% Channel
rxSig = awgn(txSigFiltered, 15);

% Simulate Frequency Offset
Fs = 1e6; 
%frequencyOffset = randi([1000 10000]); % Frequency offset in Hz
frequencyOffset = 100000;
t = (0:length(rxSig)-1)'/(Fs*sps); % Time vector in seconds
rxSig = rxSig .* exp(1i * 2 * pi * frequencyOffset * t); % Apply frequency offset

% Apply a phase shift
phi = 160; % Phase shift of x degrees
rxSig = rxSig * exp(1i * deg2rad(phi));



% Filter the received signal. Remove a portion of the signal to account for the filter delay.
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



% Symbol Synchronizer (Timing) --------------------------------------------
symbolSync = comm.SymbolSynchronizer(...
    'TimingErrorDetector', 'Gardner (non-data-aided)', ...
    'DampingFactor', 0.7, ...
    'NormalizedLoopBandwidth', 0.01, ...
    'SamplesPerSymbol', sps); 

% Correct timing errors, downsamples by sps
rxSigSync = symbolSync(rxSigCoarse);


%----------------------------FRAME SYNC-----------------------------------
% PSK modulate barkerSequence used in transmission
barkerSymbols = pskmod(barkerSequence, M, pi/M, 'gray');
detector = comm.PreambleDetector(barkerSymbols.', 'Threshold', 35);
idx = detector(rxSigSync)
dataStartIdx = idx+1;
rxSigFrame = rxSigSync(dataStartIdx:end);


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
rxData = pskdemod(rxSigFine , M, pi/M, 'gray');

% Error calculation
numErrs = symerr(data, rxData)

% Scatter plots
%scatterplot(txSig);
%scatterplot(rxSig);
scatterplot(rxSigFiltered);
scatterplot(rxSigCoarse);
scatterplot(rxSigSync);
scatterplot(rxSigFrame);
scatterplot(rxSigPhase);
scatterplot(rxSigFine);
%eyediagram(rxSigPhase,3);

%fft
%doFFT(rxSig, M, Fs);





