function [rxSigPhaseCorrected, estPhaseShiftDeg] = estimatePhaseOffset(rxSigFrame, barkerSequence, M)

    % Estimates and corrects phase offset in the received signal frame
    % Use known pilot symbols for phase estimation
    % Modulate the known pilot sequence

    expectedPilotSymbols = pskmod(barkerSequence(2:end), M, pi/M, 'gray');

    

    % Assuming the first 'n' samples in rxSigFrame are pilot symbols

    numPilotSymbols = length(expectedPilotSymbols);

    receivedPilotSymbols = rxSigFrame(1:numPilotSymbols);

    

    % Calculate phase differences

    phaseDifferences = angle(receivedPilotSymbols .* conj(expectedPilotSymbols.'));

    

    % Estimate the phase shift as the mean of the phase differences

    estPhaseShift = mean(phaseDifferences);

    estPhaseShiftDeg = rad2deg(estPhaseShift);

    

    % Correct for phase shift

    rxSigPhaseCorrected = rxSigFrame * exp(-1i * estPhaseShift);

end
