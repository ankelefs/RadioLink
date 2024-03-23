function [rxSigPhaseCorrected, estPhaseShift, estPhaseShiftDeg] = estimatePhaseOffset(rxSigFrame, barkerSequence, M, rxSigSync, dataStartIdx)
    % Estimates and corrects phase offset in the received signal frame
    % Use known pilot symbols for phase estimation

    expectedPilotSymbols = pskmod(barkerSequence(1:end), M, pi/M, 'gray');
    
    % Assuming the first 'n' samples in rxSigFrame are pilot symbols
    numPilotSymbols = length(expectedPilotSymbols);
    %if dataStartIdx <= numPilotSymbols
        % Calculate the offset into the expectedPilotSymbols based on dataStartIdx
    %    offset = numPilotSymbols - dataStartIdx +2;
        % Adjust the expectedPilotSymbols to start from the offset that aligns with the buffer start
    %    expectedPilotSymbols = expectedPilotSymbols(offset:end);
        % The received pilot symbols will be from the start of the buffer up to dataStartIdx
    %    receivedPilotSymbols = rxSigSync(1:dataStartIdx-1);
    
    if dataStartIdx == 1
       % If the packet comes from previouspackage, use the previous phase
       % shift for simplicity, was pain to fix with how it is set up now
       rxSigPhaseCorrected = rxSigFrame * exp(-1i * previousPhaseShift);
       estPhaseShift = previousPhaseShift;
       estPhaseShiftDeg = rad2deg(estPhaseShift);
       
    else
        
        receivedPilotSymbols = rxSigSync(dataStartIdx-numPilotSymbols:dataStartIdx-1);
    

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
    
    
  
end
