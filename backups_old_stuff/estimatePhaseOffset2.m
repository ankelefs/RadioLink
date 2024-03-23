function [rxSigPhaseCorrected, estPhaseShiftDeg] = estimatePhaseOffset2(rxSigFrame, barkerSequence, M, packetStartIdx)
    % Estimates and corrects phase offset in the received signal frame
    % Use known pilot symbols for phase estimation

    expectedPilotSymbols = pskmod(barkerSequence(1:end), M, pi/M, 'gray');
    
    % Assuming the first 'n' samples in rxSigFrame are pilot symbols
    numPilotSymbols = length(expectedPilotSymbols);
    
    receivedPilotSymbols = rxSigFrame(packetStartIdx:packetStartIdx+numPilotSymbols-1);
    
    % Calculate complex phase differences
    complexDiffs = receivedPilotSymbols .* conj(expectedPilotSymbols.');
    
    % Average the complex representations of the phase differences
    meanComplexDiff = mean(complexDiffs);
    
    % Calculate the angle of the mean complex difference for the phase estimate
    estPhaseShift = angle(meanComplexDiff);
    estPhaseShiftDeg = rad2deg(estPhaseShift);
    
    % Remove barker sequence from data
    rxSigFrame = rxSigFrame(numPilotSymbols+1:end);
    % Correct for phase shift
    rxSigPhaseCorrected = rxSigFrame * exp(-1i * estPhaseShift);
end
