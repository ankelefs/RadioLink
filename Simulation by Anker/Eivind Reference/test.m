% Modulate signal M-PSK 
M = 4;

% Model speech as random data
data = randi([0 M-1], 10000, 1);
data2 = randi([0 M-1], 10000, 1);
%data = repmat(3,10000,1);

% Barker Code sequence
barkerCode = [1, 1, 1, 1, 1, -1, -1, 1, 1, -1, 1, -1, 1]; % Barker code length 13
barkerCodeMapped = (barkerCode + 1)/2; % Mapping [-1, 1] to [0, 1] for QPSK
barkerCodeMapped2 = barkerCodeMapped+2;
barkerSequence = [barkerCodeMapped, barkerCodeMapped2];
packet = [data2;barkerSequence.'; data];         % Concenate with random data


% M-PSK modulate 
txSig = pskmod(packet, M, pi/M, 'gray'); % input, modulation order, phase offset, symbol order


% RRC Filter parameters
rolloff = 0.5;  % Roll-off factor
span = 8;      % Filter span in symbols
sps = 4;        % Samples per symbol

% Create RRC Filters
rrcFilter = rcosdesign(rolloff, span, sps);

% Apply rrcFilter to txSig. Upsample by sps
txSigFiltered = upfirdn(txSig, rrcFilter, sps);
rxSig = awgn(txSig,20);


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


% PSK modulate barkerSequence used in transmission
barkerSymbols = pskmod(barkerSequence, M, pi/M, 'gray');
detector = comm.PreambleDetector(barkerSymbols.', 'Threshold', 20);
idx = detector(rxSig)
dataStartIdx = idx+1;
% Er noe funky greier her, siste dataen er helt lik, men vi mangler 5
% sampler på starten
rxSigFrame = txSig(dataStartIdx:end);
rxData = pskdemod(rxSigFrame, M, pi/M, 'gray');
symerr(data,rxData)