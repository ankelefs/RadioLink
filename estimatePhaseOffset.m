function [rxSigPhaseCorrected, estPhaseShiftDeg] = estimatePhaseOffset(rxSigFrame, barkerSequence, M, rxSigSync, dataStartIdx)
    % Estimates and corrects phase offset in the received signal frame
    % Use known pilot symbols for phase estimation

    expectedPilotSymbols = pskmod(barkerSequence(1:end), M, pi/M, 'gray');
    
    % Assuming the first 'n' samples in rxSigFrame are pilot symbols
    numPilotSymbols = length(expectedPilotSymbols)
    receivedPilotSymbols = rxSigSync(dataStartIdx-numPilotSymbols:dataStartIdx-1);
    length(receivedPilotSymbols)
    % Calculate complex phase differences
    complexDiffs = receivedPilotSymbols .* conj(expectedPilotSymbols.')
    
    % Average the complex representations of the phase differences
    meanComplexDiff = mean(complexDiffs)
    
    % Calculate the angle of the mean complex difference for the phase estimate
    estPhaseShift = angle(meanComplexDiff);
    estPhaseShiftDeg = rad2deg(estPhaseShift);
    
    % Correct for phase shift
    rxSigPhaseCorrected = rxSigFrame * exp(-1i * estPhaseShift);
end
