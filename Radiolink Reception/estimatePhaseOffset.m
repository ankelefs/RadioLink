function [rxSignal_PhaseCorrected, estimatedPhaseShift, estimatedPhaseShiftDegrees] = estimatePhaseOffset( ...
    rxSignal_Frame, ...
    barkerSequence, ...
    modulationOrder, ...
    rxSignal_Synchronized, ...
    dataStartIndex, ...
    previousPhaseShift ...
    )
    



% Estimate and correct phase offset in the received signal frame by
% using known pilot symbols.
expectedPilotSymbols = pskmod(barkerSequence(1:end), modulationOrder, pi/modulationOrder, 'gray');


% Assuming the first 'n' samples in signal frame are pilot symbols
numPilotSymbols = length(expectedPilotSymbols);


if dataStartIndex == 1
    % If the packet comes from the previous package, use the previous phase
    % shift estimate for simplicity.
    rxSignal_PhaseCorrected = rxSignal_Frame * exp(-1i * previousPhaseShift);
    estimatedPhaseShift = previousPhaseShift;
    estimatedPhaseShiftDegrees = rad2deg(estimatedPhaseShift);
else
    receivedPilotSymbols = rxSignal_Synchronized(dataStartIndex - numPilotSymbols:dataStartIndex - 1);


    % Calculate complex phase differences
    complexDifferences = receivedPilotSymbols .* conj(expectedPilotSymbols.');


    % Average the phase differences.
    meanComplexDifferences = mean(complexDifferences);


    % Calculate the angle of the mean complex difference for the phase
    % estimate.
    estimatedPhaseShift = angle(meanComplexDifferences);
    estimatedPhaseShiftDegrees = rad2deg(estimatedPhaseShift);

    
    % Correct for the phase shift
    rxSignal_PhaseCorrected = rxSignal_Frame * exp(-1i * estimatedPhaseShift);
end
