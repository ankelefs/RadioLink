%*************************************************************************
% Filename: channel.m
%
% Contents: This file contains the simulated channel block.
%*************************************************************************


function channelSignal = channel(txSignal,samplingFrequency)

    channelSignal = awgn(txSignal,10,"measured");   % AWGN added based relative to measurements of signal
    % definedPlot(channelSignal, 3, "channelSignal");


    % Simulate a frequency offset
    % Difference between the LO at the Tx and the Rx 
    frequencyOffset = 15000;                                            % Frequency offset in Hz
    % frequencyOffset = randi([2000 20000]);                              % Random frequency offset in Hz
    t = (0:length(channelSignal)-1)'/samplingFrequency;                 % Time vector in seconds
    channelSignal = channelSignal.*exp(1i*2*pi*frequencyOffset*t);      % Apply frequency offset
    

    % Simulate a phase shift
    % phi = 35;                                                   % Phase shift of x degrees
    % channelSignal = channelSignal*exp(1i*deg2rad(phi));         % Apply phase shift

end