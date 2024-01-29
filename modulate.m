% Modulate signal M-PSK 
M = 4;
% Assume data is known (random for fun)
data = randi([0 M-1], 1000000, 1);
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
rxSig = awgn(txSigFiltered, 10);


% Apply a phase shift
phi = 0; % Phase shift of 45 degrees
rxSig = rxSig * exp(1i * phi);

% Filter and downsample the received signal. Remove a portion of the signal to account for the filter delay.
rxSigFiltered = upfirdn(rxSig, rrcFilter, 1, sps);
rxSigFiltered = rxSigFiltered(span+1:end-span);

% Demodulate
rxData = pskdemod(rxSigFiltered, M, pi/M, 'gray');

% Error calculation
numErrs = symerr(data, rxData);

% Scatter plots
scatterplot(txSig);
scatterplot(rxSig);
scatterplot(rxSigFiltered);