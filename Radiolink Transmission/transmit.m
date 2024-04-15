function transmit(txSignal, pulseShapeFilter, samplesPerSymbol, txRadioObject, counter)



    
% Apply pulse shape filter and upsample with samplesPerSymbol
txSignal_Filtered = upfirdn(txSignal, pulseShapeFilter, samplesPerSymbol);

% Transmit the signal.
%transmitRepeat(txRadioObject, txSignal_Filtered);            % Repeated packet transmission.
txRadioObject(txSignal_Filtered);                           % Single packet transmission.

disp("Packet    #" + counter + " transmitted.")