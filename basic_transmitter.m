% Basic Sinusoidal Wave Transmission using ADALM-PLUTO

% Parameters are loaded with params.m
run('params.m');



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
