function [rxSigFrames, partialPacket, packetCompletes, dataStartIdxs] = extractPackets(inputSignal, barkerSequence, M, dataLength, overlapBuffer, partialPacket)

    rxSigFrames = {};
    packetCompletes = [];
    dataStartIdxs = [];
    overlapBufferLength = length(overlapBuffer)-1;
    barkerLen = 26;

    % Check and complete any existing partialPacket first
   if ~isempty(partialPacket)

            % How much more of the packet we are expecting.
            neededLength =  overlapBufferLength + dataLength - length(partialPacket) - 1;
            % Directly complete the packet with the beginning of inputSignal, since
            rxSigFrame = [partialPacket; inputSignal(overlapBufferLength:neededLength)];
            rxSigFrames{end+1} = rxSigFrame; % Store the completed packet
            partialPacket = []; % Clear the partialPacket as it's now been used
            packetCompletes(end+1) = true;
            dataStartIdxs(end+1) = 1; % DATA WILL INCLUDE BARKER CODE FOR PARTIALPACKETS!!!
    end

    % PSK modulate barkerSequence used in transmission
    barkerSymbols = pskmod(barkerSequence, M, pi/M, 'gray');
    detector = comm.PreambleDetector(barkerSymbols.', 'Threshold', 18);
   
    % Detect new packets in the remaining inputSignal
    idx = detector(inputSignal);
    
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
            % Packet spans into the next buffer, store the partial part
            % This is handled by overlapbuffer now
            % For a partial packet we also include the barkersequence so we can estimate the phase
            %partialPacket = inputSignal(dataStartIdx:end); 
            break; % Assume only one packet can span buffers at a time
        end
    end

end
