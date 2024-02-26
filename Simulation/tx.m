%*************************************************************************
% Filename: tx.m
%
% Contents: This file contains the transmitter block.
%*************************************************************************


function txSignal = tx(data,numberOfSymbols,rollOffFactor,filterSpan,samplesPerSymbol)

    addpath('/');

    
    % Modulate data using QPSK and grey-coding
    txSignal_Modulated = pskmod(...
        data,...
        numberOfSymbols,...
        pi/numberOfSymbols,...
        "gray",...
        "InputType","bit",...
        "OutputDataType","double");    
    definedPlot(txSignal_Modulated, 3, "txSignal Modulated", 1);
    % disp("txSignal_Modulated");
    % disp(txSignal_Modulated);
    

    % Create a root raised cosine filter
    rootRaisedCosineFilter = rcosdesign(rollOffFactor,filterSpan,samplesPerSymbol);   
    % definedPlot(rootRaisedCosineFilter, 2, "Root Raised Cosine Filter", 2);
    

    % Apply filter and upsample by samplesPerSymbol
    txSignal_Filtered = upfirdn(txSignal_Modulated,rootRaisedCosineFilter,samplesPerSymbol);    
    % definedPlot(txSignal_Filtered, 1, "txSignal Filtered", 3);
    % disp("txSignal_Filtered");
    % disp(txSignal_Filtered);


    txSignal = txSignal_Filtered;

end