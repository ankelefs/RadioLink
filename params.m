%parameters for both transmitter and receiver

fs = 1e6;          % Sample rate in Hz
fc = 1.7975e9;      % Center frequency in Hz (DO NOT USE ILLEGAL BANDS)
numSamples = 1024; % Number of samples per frame

%Additional parameters for the transmitter
duration = 5;      %Duration of signal in seconds
M = 4;

%Create random qpsk signal
% Modulate signal M-PSK 
M = 4;


% Barker Code sequence
barkerCode = [1, 1, 1, 1, 1, -1, -1, 1, 1, -1, 1, -1, 1]; % Barker code length 13
barkerCodeMapped = (barkerCode + 1)/2; % Mapping [-1, 1] to [0, 1] for QPSK
barkerCodeMapped2 = barkerCodeMapped+2;
barkerSequence = [barkerCodeMapped, barkerCodeMapped2,barkerCodeMapped, barkerCodeMapped2];


% RRC Filter parameters
rolloff = 0.5;  % Roll-off factor
span = 12;      % Filter span in symbols
sps = 8;        % Samples per symbol

% Create RRC Filters
rrcFilter = rcosdesign(rolloff, span, sps);
%Think this is useless if we use psk
%amplitude = 0.75;  
%frequency = 100e3; %Frequency of the baseband wave
%w = 2*pi*frequency; 
% Calculate the time vector
%t = 0:1/fs:duration-1/fs;
% Generate the sinusoidal signal
%s1 = amplitude*exp(1i*w*t);
%s1 = s1(:); % Transpose it, but DON'T complex conjugate as s1' does