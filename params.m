%parameters for both transmitter and receiver

fs = 1e6;          % Sample rate in Hz
fc = 1.7975e9;      % Center frequency in Hz (DO NOT USE ILLEGAL BANDS)


%Additional parameters for the transmitter
duration = 5;      %Duration of signal in seconds

%Create random qpsk signal
% Modulate signal M-PSK 
M = 4;

% Barker Code sequence
barkerCode = [1, 1, 1, 1, 1, -1, -1, 1, 1, -1, 1, -1, 1]; % Barker code length 13
barkerCodeMapped = (barkerCode + 1)/2; % Mapping [-1, 1] to [0, 1] for QPSK
barkerCodeMapped2 = barkerCodeMapped+2;
barkerSequence = [barkerCodeMapped, barkerCodeMapped2];


% RRC Filter parameters
rolloff = 0.5;  % Roll-off factor
span = 12;      % Filter span in symbols
sps = 8;        % Samples per symbol

% Create RRC Filters
rrcFilter = rcosdesign(rolloff, span, sps);

% Model speech as random data
data = randi([0 M-1], 1000, 1);
%load('data_known.mat')


packet = [barkerSequence.'; data];         % Concenate with random data

% M-PSK modulate 
txSig = pskmod(packet, M, pi/M, 'gray'); % input, modulation order, phase offset, symbol order


% Apply rrcFilter to txSig. Upsample by sps
txSigFiltered = upfirdn(txSig, rrcFilter, sps);


dataLength = length(data);
numSamples = 2*dataLength*sps; % Number of samples per frame (MUST BE AT LEAST 2 x PACKET LENGTH)
% Assuming numSamples is defined in 'params.m'
overlapSize = 512; % Define overlap size based on your preamble length and expected signal characteristics
overlapBuffer = zeros(overlapSize, 1); % Buffer to store the last part of the previous buffer for overlap
partialPacket = []; % Initialization is crucial before its first use

