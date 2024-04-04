% Load the audio file
[audioDataOriginal, fss] = audioread('CantinaBand3.wav');
fs = 1e6;          % Sample rate in Hz
fc = 1.7975e9;      % Center frequency in Hz (DO NOT USE ILLEGAL BANDS)


% Ensure audio data is mono by averaging if stereo
if size(audioDataOriginal, 2) == 2
    audioData = mean(audioDataOriginal, 2);
else
    audioData = audioDataOriginal;
end

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



% Packetization parameters
dataLength = 1000; % Number of symbols per packet
numSamples = 20*dataLength*sps; % Number of samples per frame (MUST BE AT LEAST 2 x PACKET LENGTH)
% Assuming numSamples is defined in 'params.m'
overlapSize = 1025; % Define overlap size based on your preamble length and expected signal characteristics
overlapBuffer = zeros(overlapSize, 1); % Buffer to store the last part of the previous buffer for overlap
partialPacket = []; % Initialization is crucial before its first use

