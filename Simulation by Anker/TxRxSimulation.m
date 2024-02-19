%*************************************************************************
% Filename: TxRxSimulation.m
%
% Contents: This file contains the full simulation of Tx and Rx. It is
% divided into (function) blocks for ease of use.
%*************************************************************************


addpath('/');
run('parameters.m');
run('transmitMessage');




% Message (data) to be transmitted
% disp(dataPacket);


% Tx block
txSignal = tx(dataPacket,numberOfSymbols,rollOffFactor,filterSpan,samplesPerSymbol);


% Channel block
channelSignal = channel(txSignal,samplingFrequency,samplesPerSymbol);


% Rx block
[rxSignal, frequencyOffsetEstimate] = rx(channelSignal,rollOffFactor,filterSpan,samplesPerSymbol,samplingFrequency);


% Demodulate received signal
demodulatedSignal = pskdemod(...
        rxSignal,...           % <— Changes during testing 
        numberOfSymbols,...
        pi/numberOfSymbols,...
        "gray",...
        OutputType="bit");


% Calculate the number of symbol (QPSK) errors
dataIn = dataPacket;
dataOut = demodulatedSignal;
numberOfErrors = symerr(dataIn,dataOut);
disp("Symbol error rate: " + numberOfErrors/length(dataIn));




% eyediagram(signal,2*samplesPerSymbol);
% definedPlot(signal, type);
% definedFFT(signal,M,samplingFrequency)








