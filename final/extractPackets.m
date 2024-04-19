function [rxSigFrames, packetCompletes, dataStartIdxs,packetNumbers] = extractPackets(inputSignal, detector, dataLength, barkerLength, headerLength)

    rxSigFrames = {};
    packetCompletes = [];
    dataStartIdxs = [];
    packetNumbers = [];
  
   
    % Detect new packets in the remaining inputSignal
    idx = detector(inputSignal)
    
    lastDataStartIdx = 0; % Track start index of last detected packet.

    
    
    for i = 1:length(idx)
        dataStartIdx = idx(i) + 1;

        if (dataStartIdx - lastDataStartIdx) < 50
            continue; % Skip the preamble if it is too close to a different one
        end
        
        headerStartIdx = dataStartIdx - barkerLength - headerLength; % Calculate start index of header
        if headerStartIdx >= 0 % Ensure header is within bounds
            headerSymbols = inputSignal(headerStartIdx:headerStartIdx + headerLength - 1);
            headerBits = de2bi(pskdemod(headerSymbols, M, pi/M, 'gray'), log2(M), 'left-msb');
            packetNumber = bi2de(reshape(headerBits.', 1, []), 'left-msb');
            packetNumbers(end+1) = packetNumber; % Append packet number to list
        else
            packetNumbers(end+1) = 999; % Error number, should not happen
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
