function [rxSigFrames, packetCompletes, dataStartIdxs] = extractPackets(inputSignal, detector, M, dataLength, overlapBuffer)

    rxSigFrames = {};
    packetCompletes = [];
    dataStartIdxs = [];
    overlapBufferLength = length(overlapBuffer)-1;
    barkerLen = 26;



   
    % Detect new packets in the remaining inputSignal
    idx = detector(inputSignal)
    
    lastDataStartIdx = 0; % Track start index of last detected packet.

    for i = 1:length(idx)
        dataStartIdx = idx(i) + 1;

        if (dataStartIdx - lastDataStartIdx) < 50
            continue; % Skip the preamble if it is too close to a different one
        end

        if (dataStartIdx + dataLength - 1) <= length(inputSignal)
            % Packet can be fully extracted from the current buffer
            lastDataStartIdx = dataStartIdx;
            rxSigFrame = inputSignal(dataStartIdx:dataStartIdx + dataLength -1);
            rxSigFrames{end+1} = rxSigFrame;
            packetCompletes(end+1) = true;
            dataStartIdxs(end+1) = dataStartIdx;
        else
 
            break; % Assume only one packet can span buffers at a time
        end
    end

end
