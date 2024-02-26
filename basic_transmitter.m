% Basic Sinusoidal Wave Transmission using ADALM-PLUTO

% Parameters are loaded with params.m
run('params.m');

%Create random qpsk signal
% Modulate signal M-PSK 
M = 4;

% Model speech as random data
data = randi([0 M-1], 100000, 1);

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



% Setup PlutoSDR System object
tx = sdrtx('Pluto');
tx.CenterFrequency = fc;
tx.BasebandSampleRate = fs;
tx.Gain = 0; 


% Transmit the signal
disp('Starting transmission...');
transmitRepeat(tx, txSigFiltered); % Continuously transmit the signal

% Stop the transmission after a specified duration
%pause(duration);
%release(tx);
%disp('Transmission stopped.');
