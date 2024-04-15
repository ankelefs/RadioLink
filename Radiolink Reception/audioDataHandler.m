function audioDataPackets = audioDataHandler( ...
    rxSignal_Frames, ...
    rxSignal_SymbolSynchronized, ...
    packetCompletions, ...
    dataStartIndexes, ...
    fineSynchronizerObject, ...
    modulationOrder, ...
    barkerSymbols, ...
    numPilotSymbols, ...
    audioFrameLength, ...
    audioBitDepth, ...
    counter ...
    )





% Initializations.
previousPhaseShift = 0;
localCounter = 1;
audioDataPackets = [];


% Iterate through each extracted packet.
for packetIndex = 1:length(rxSignal_Frames) 
    rxSignal_Frame = rxSignal_Frames{packetIndex};      % Extracted packet.
    packetComplete = packetCompletions(packetIndex);    % Completion status of the packet.
    dataStartIndex = dataStartIndexes(packetIndex);     % Start index of the packet.
    

    % PROBLEM: partialPacket does not have index, so iteration through
    % rxSignal_Frame is not possible.


    % Only proceed with phase correction and further processing if a
    % complete packet was extracted.
    if packetComplete
        % Phase correction.
        [rxSignal_PhaseCorrected, estimatedPhaseShift, estimatedPhaseShiftDegrees] = estimatePhaseOffset( ...
            rxSignal_Frame, ...
            rxSignal_SymbolSynchronized, ...
            dataStartIndex, ...
            previousPhaseShift, ...
            barkerSymbols, ...
            numPilotSymbols ...
            );
        
        
        % Fine frequency and fine phase synchronization.
        rxSignal_FineAdjusted = fineSynchronizerObject(rxSignal_PhaseCorrected);
        
        
        % Demodulate back into audio bits.
        rxSignal_Demodulated = pskdemod(rxSignal_FineAdjusted, modulationOrder, pi/modulationOrder, 'gray', 'OutputType', 'bit');

        
        % Decode into integer values.
        %test = bit2int(rxSignal_Demodulated, audioBitDepth)
        audioDataPackets = [audioDataPackets; bit2int(rxSignal_Demodulated, audioBitDepth)];
    
    
        disp("Packet    #" + counter + "." + localCounter + " decoded.")
        localCounter = localCounter + 1;
    end  
end