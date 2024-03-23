function [rxSigFrames, partialPacket, packetCompletes, packetStartIdxs] = extractPackets2(inputSignal, barkerSequence, M, dataLength, overlapBuffer, partialPacket)

    rxSigFrames = {};
    packetCompletes = [];
    packetStartIdxs = [];
    overlapBufferLength = length(overlapBuffer)-1;
    barkerLen = 26;
    packetLen = dataLength + barkerLen;

    % Check and complete any existing partialPacket first
   if ~isempty(partialPacket)

            % How much more of the packet we are expecting.
            neededLength = packetLen - length(partialPacket) + overlapBufferLength - 1;
            % Directly complete the packet with the beginning of inputSignal, since
            rxSigFrame = [partialPacket; inputSignal(overlapBufferLength:neededLength)];
            rxSigFrames{end+1} = rxSigFrame; % Store the completed packet
            partialPacket = []; % Clear the partialPacket as it's now been used
            packetCompletes(end+1) = true;
            packetStartIdxs(end+1) = 1; % Packet will start at idx 1
    end

    % PSK modulate barkerSequence used in transmission
    barkerSymbols = pskmod(barkerSequence, M, pi/M, 'gray');
    detector = comm.PreambleDetector(barkerSymbols.', 'Threshold', 15);
   
    % Detect new packets in the remaining inputSignal
    idx = detector(inputSignal);
    
    lastPacketStartIdx = 0; % Track start index of last detected packet.

    for i = 1:length(idx)
        packetStartIdx = idx(i) + 1 - barkerLen;

        if (packetStartIdx - lastPacketStartIdx) < 50
            continue; % Skip the preamble if it is too close to a different one
        end

        if (packetStartIdx + packetLen - 1 ) <= length(inputSignal)
            % Packet can be fully extracted from the current buffer
            lastPacketStartIdx = packetStartIdx;
            rxSigFrame = inputSignal(packetStartIdx:packetStartIdx + packetLen-1);
            rxSigFrames{end+1} = rxSigFrame;
            packetCompletes(end+1) = true;
            packetStartIdxs(end+1) = packetStartIdx;
        else
            % Packet spans into the next buffer, store the partial part
            % For a partial packet we also include the barkersequence so we can estimate the phase
            partialPacket = inputSignal(packetStartIdx:end); 
            break; % Assume only one packet can span buffers at a time
        end
    end

end
