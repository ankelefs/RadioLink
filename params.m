%parameters for both transmitter and receiver

fs = 1e6;          % Sample rate in Hz
fc = 1.775e9;      % Center frequency in Hz (DO NOT USE ILLEGAL BANDS)
numSamples = 1024; % Number of samples per frame

%Additional parameters for the transmitter
duration = 5;      %Duration of signal in seconds


%Think this is useless if we use psk
%amplitude = 0.75;  
%frequency = 100e3; %Frequency of the baseband wave
%w = 2*pi*frequency; 
% Calculate the time vector
%t = 0:1/fs:duration-1/fs;
% Generate the sinusoidal signal
%s1 = amplitude*exp(1i*w*t);
%s1 = s1(:); % Transpose it, but DON'T complex conjugate as s1' does