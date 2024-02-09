%*************************************************************************
% Filename: rootRaisedCosineFilterTx.m
%
% Function: Creates a root-raised cosine filter for the Tx with gain G = 1.
%*************************************************************************


function outputFilter = raisedCosineTxFilter(numberOfSymbolDurations, rollOffFactor, samplesPerSymbol, plotFilter, holdOn)
    rctFilt = comm.RaisedCosineTransmitFilter(...
        Shape = 'Normal', ...
        RolloffFactor = rollOffFactor, ...
        FilterSpanInSymbols = numberOfSymbolDurations, ...
        OutputSamplesPerSymbol = samplesPerSymbol);
    
    outputFilter = rctFilt;

    if plotFilter
        if not(holdOn)
            figure();
        end
        impz(rctFilt.coeffs.Numerator); % Visualize the impulse response
        xlabel("Samples (n)");
        grid on;

        if holdOn
            hold on;
        end
    end
end