function [rxSigFrames, packetCompletes, dataStartIdxs, packetNumbers] = extractHeaderPackets(inputSignal, barkerSequence, M, dataLength)
    rxSigFrames = {};
    packetCompletes = [];
    dataStartIdxs = [];
    packetNumbers = []; % To store packet numbers
    barkerLen = 26; % Adjusted for both barker sequence and header
    headerSymbols = 8; % Number of symbols used for the header


    % PSK modulate barkerSequence used in transmission
    barkerSymbols = pskmod(barkerSequence, M, pi/M, 'gray');
    detector = comm.PreambleDetector(barkerSymbols.', 'Threshold', 18);
    
    % Detect new packets in the remaining inputSignal
    idx = detector(inputSignal)
    
    lastDataStartIdx = 0; % Track start index of last detected packet.

    for i = 1:length(idx)
        dataStartIdx = idx(i) + barkerLen + headerSymbols; % Adjust index to account for header

        if (dataStartIdx - lastDataStartIdx) < (barkerLen + headerSymbols + 50)
            continue; % Skip detections too close to each other
        end

        if (dataStartIdx + dataLength - 1) <= length(inputSignal)
            % Packet can be fully extracted, including header
            lastDataStartIdx = dataStartIdx;
            headerStartIdx = idx(i) + barkerLen; % Start index for the header
            headerEndIdx = headerStartIdx + headerSymbols - 1;
            rxSigFrame = inputSignal(dataStartIdx:dataStartIdx + dataLength -1);
            headerFrame = inputSignal(headerStartIdx:headerEndIdx); % Extract header
            packetNumber = pskdemod(headerFrame, M, pi/M, 'gray'); % Demodulate header to get packet number
            packetNumber = bi2de(reshape(de2bi(packetNumber, 'left-msb'), [], 1).', 'left-msb');
            
            rxSigFrames{end+1} = rxSigFrame;
            packetCompletes(end+1) = true;
            dataStartIdxs(end+1) = dataStartIdx;
            packetNumbers(end+1) = packetNumber; % Store demodulated packet number
        else
            break; % Assume only one packet spans buffers at a time
        end
    end
end
