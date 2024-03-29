%*************************************************************************
% Filename: TxRxSimulation.m
%
% Contents: This file contains the full simulation of Tx and Rx. It is
% divided into (function) blocks for ease of use.
%*************************************************************************


addpath('/');


% Parameters
bits = 1E2;
samplingFrequency = 61.44E6;                % MSPS from the Adalm-Pluto's datasheet
carrierFrequency = 1.7975E9;                % 1.7975 GHz carrier frequency
bitsPerSymbol = 2;
numberOfSymbols = 2^bitsPerSymbol;
rollOffFactor = 0.5;  
filterSpan = 12;                            % [Samples]
samplesPerSymbol = 8;  


%********************************
plotOptionTx = 1;
plotOptionChannel = 1;
plotOptionRx = 1;
%********************************




% Data to transmit
data = randi([0,1],bits,1);                                     
% Barker code sequence
barkerCode = [1, 1, 1, 1, 1, 0, 0, 1, 1, 0, 1, 0, 1]';          % Barker code of length 13. Column vector
% Combined data packet
dataPacket = [barkerCode; barkerCode; data];                    


% Radio link simulation
txSignal = tx(dataPacket, numberOfSymbols, rollOffFactor, filterSpan, samplesPerSymbol, samplingFrequency, carrierFrequency, plotOptionTx);
channelSignal = channel(txSignal, samplingFrequency, carrierFrequency, plotOptionChannel);                                                                   
% [rxSignal, frequencyOffsetEstimate] = rx(...
    % channelSignal, ... 
    % rollOffFactor, ... 
    % filterSpan, ...
    % samplesPerSymbol, ...
    % samplingFrequency, ...
    % barkerCode, ...
    % carrierFrequency, ...
    % plotOptionRx);


% Demodulate received signal
% rxSignal_demodulated = pskdemod( ...
        % rxSignal, ...
        % numberOfSymbols, ...
        % pi/numberOfSymbols, ...
        % 'gray', ...
        % 'OutputType', 'bit');


% Calculate the number of bit errors
% numberOfErrors = symerr(dataPacket,rxSignal_demodulated);
% disp("Bit error rate: " + numberOfErrors/length(dataIn)*100 + " %");




% eyediagram(signal,2*samplesPerSymbol);
% definedFFT(signal,M,samplingFrequency)








