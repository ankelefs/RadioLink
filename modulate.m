% Modulate signal M-PSK 
M = 4;
% Model speech data is random 

data = randi([0 M-1], 10000, 1);
txSig = pskmod(data, M, pi/M, 'gray'); % input, modulation order, phase offset, symbol order

% RRC Filter parameters
rolloff = 0.5;  % Roll-off factor
span = 10;      % Filter span in symbols
sps = 4;        % Samples per symbol

% Create RRC Filters
rrcFilter = rcosdesign(rolloff, span, sps);

% Apply Transmit Filter (Upsample and filter)
txSigFiltered = upfirdn(txSig, rrcFilter, sps);



% Channel
rxSig = awgn(txSigFiltered, 20);


% Simulate Frequency Offset
Fs = 1e6; % Sample rate in samples per symbol
%frequencyOffset = randi([1000 10000]); % Frequency offset in Hz
frequencyOffset = 100000;
t = (0:length(rxSig)-1)'/Fs; % Time vector in seconds
rxSig = rxSig .* exp(1i * 2 * pi * frequencyOffset * t); % Apply frequency offset

% Apply a phase shift
%phi = randi([20 45]); % Phase shift of x degrees
%rxSig = rxSig * exp(1i * phi);




%RECEIVER CHAIN START
% Create AGC and apply to received signal
%agc = comm.AGC;
%rxSig = agc(rxSig);



% Filter and downsample the received signal. Remove a portion of the signal to account for the filter delay.
rxSigFiltered = upfirdn(rxSig, rrcFilter, 1, sps);
rxSigFiltered = rxSigFiltered(span+1:end-span);

%coarse frequency compensation
[rxSigCompensated,estimatedFreqOffset] = coarseFreqComp(rxSigFiltered, Fs,M, 1000);

% Demodulate
rxData = pskdemod(rxSigCompensated, M, pi/M, 'gray');

% Error calculation
numErrs = symerr(data, rxData);

% Scatter plots
%scatterplot(txSig);
%scatterplot(rxSig);
scatterplot(rxSigFiltered);
scatterplot(rxSigCompensated);
%eyediagram(rxSigFiltered,3);

%fft
doFFT(rxSigFiltered, M, Fs);
doFFT(rxSigCompensated, M, Fs);




