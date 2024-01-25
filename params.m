%parameters for both transmitter and receiver

fs = 1e6;          % Sample rate in Hz
fc = 1.775e9;      % Center frequency in Hz (DO NOT USE ILLEGAL BANDS)
numSamples = 1024; % Number of samples per frame

%Additional parameters for the transmitter
duration = 5;      %Duration of signal in seconds
amplitude = 0.75;  
frequency = 100e3; %Frequency of the baseband wave

