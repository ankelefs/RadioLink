% Basic Sinusoidal Wave Transmission using ADALM-PLUTO

% Parameters are loaded with params.m
run('params.m');

%Create random qpsk signal
%Modulate signal M-PSK 
M = 4;
% Model speech data as known data
data = repmat([3, 2, 1], 1, 30);
%Pilot sequence
pilotSequence = repmat([1, 1, 1, 3], 1, 4); % Repeat sequence N times
data = [pilotSequence'; data'];              % Concenate with random data

%scatterplot(txSig);

% RRC Filter parameters
rolloff = 0.5;  % Roll-off factor
span = 8;      % Filter span in symbols
sps = 4;        % Samples per symbol

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
