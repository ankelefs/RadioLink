% Basic Sinusoidal Wave Transmission using ADALM-PLUTO

% Parameters are loaded with params.m
run('params.m');

% Omega
w = 2*pi*frequency; 


% Calculate the time vector
t = 0:1/fs:duration-1/fs;


% Generate the sinusoidal signal
s1 = amplitude*exp(1i*w*t)+(amplitude/2);
s1 = s1(:); % Transpose it, but DON'T complex conjugate as s1' does

% Setup PlutoSDR System object
tx = sdrtx('Pluto');
tx.CenterFrequency = fc;
tx.BasebandSampleRate = fs;
tx.Gain = -10; 

% Transmit the signal
disp('Starting transmission...');
transmitRepeat(tx, s1); % Continuously transmit the signal

% Stop the transmission after a specified duration
%pause(duration);
%release(tx);
%disp('Transmission stopped.');
