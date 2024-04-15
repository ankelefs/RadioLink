function [rxSignal_Frames, partialPacket, packetCompletions, dataStartIndexes] = extractPackets( ...
    rxSignal_SymbolSynchronized, ...
    preambleDetectorObject, ...
    informationDataSize, ...
    modulationOrder, ...
    partialPacket ...
    )




% Initializations.
rxSignal_Frames = {};
packetCompletions = [];
dataStartIndexes = [];




% Track start index of last detected packet.
lastDataStartIndex = 0; 


% Fetch all indexes where the Barker sequence is measured.
preambleDetectorIndexes = preambleDetectorObject(rxSignal_SymbolSynchronized);


for i = 1:length(preambleDetectorIndexes)
    dataStartIndex = preambleDetectorIndexes(i) + 1;


    % Skip the preamble if it is too close to a different one.
    if (dataStartIndex - lastDataStartIndex) < 50
        continue; 
    end
    

    % Check if packet can be fully extracted from the current buffer.
    if (dataStartIndex + informationDataSize - 1) <= length(rxSignal_SymbolSynchronized)
        lastDataStartIndex = dataStartIndex;
        rxSignal_Frame = rxSignal_SymbolSynchronized(dataStartIndex:dataStartIndex + (informationDataSize / log2(modulationOrder)) -1);
        rxSignal_Frames{end + 1} = rxSignal_Frame;
        packetCompletions(end + 1) = true;
        dataStartIndexes(end + 1) = dataStartIndex;
    else
        % Packet spans into the next buffer, store the partial part.
        % NOTE: Assume only one packet can span buffers at a time
        % For a partial packet we also include the Barker sequence so we
        % can estimate the phase.
        % NOTE: This is handled by the overlap buffer:
        % partialPacket = inputSignal(dataStartIdx:end); 
        break;
    end
end
