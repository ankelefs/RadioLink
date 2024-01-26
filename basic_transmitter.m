% Basic Sinusoidal Wave Transmission using ADALM-PLUTO

% Parameters are loaded with params.m
run('params.m');

%Create random qpsk signal
%Modulate signal M-PSK 
M = 4;
%Assume data is known (random for fun)
data = randi([0 M-1],1000,1);
txSig = pskmod(data,M, pi/M, 'gray'); %input, modulation order, phase offset, symbol order
%scatterplot(txSig);





% Setup PlutoSDR System object
tx = sdrtx('Pluto');
tx.CenterFrequency = fc;
tx.BasebandSampleRate = fs;
tx.Gain = 0; 


% Transmit the signal
disp('Starting transmission...');
transmitRepeat(tx, txSig); % Continuously transmit the signal

% Stop the transmission after a specified duration
%pause(duration);
%release(tx);
%disp('Transmission stopped.');
