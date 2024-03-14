function [rxSigPhaseCorrected, estPhaseShiftDeg] = estimatePhaseOffset(rxSigFrame, barkerSequence, M, rxSigSync, dataStartIdx, partialBarker)
    % Estimates and corrects phase offset in the received signal frame
    % Use known pilot symbols for phase estimation

    expectedPilotSymbols = pskmod(barkerSequence(1:end), M, pi/M, 'gray');
    
    % Assuming the first 'n' samples in rxSigFrame are pilot symbols
    numPilotSymbols = length(expectedPilotSymbols);
    if (1 < dataStartIdx) && (dataStartIdx <= numPilotSymbols)
        % Calculate the offset into the expectedPilotSymbols based on dataStartIdx
        offset = numPilotSymbols - dataStartIdx +2;
        % Adjust the expectedPilotSymbols to start from the offset that aligns with the buffer start
        expectedPilotSymbols = expectedPilotSymbols(offset:end);
        % The received pilot symbols will be from the start of the buffer up to dataStartIdx
        receivedPilotSymbols = rxSigSync(1:dataStartIdx-1);
    elseif dataStartIdx == 1
            receivedPilotSymbols = partialBarker;
    else
        
        receivedPilotSymbols = rxSigSync(dataStartIdx-numPilotSymbols:dataStartIdx-1);
    end
    
    %receivedPilotSymbols = rxSigSync(dataStartIdx-numPilotSymbols:dataStartIdx-1);
    % Calculate complex phase differences
    complexDiffs = receivedPilotSymbols .* conj(expectedPilotSymbols.');
    
    % Average the complex representations of the phase differences
    meanComplexDiff = mean(complexDiffs);
    
    % Calculate the angle of the mean complex difference for the phase estimate
    estPhaseShift = angle(meanComplexDiff);
    estPhaseShiftDeg = rad2deg(estPhaseShift);
    
    % Correct for phase shift
    rxSigPhaseCorrected = rxSigFrame * exp(-1i * estPhaseShift);
end
