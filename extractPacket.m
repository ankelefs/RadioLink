function [rxSigFrame, partialPacket, packetComplete, dataStartIdx] = extractPacket(rxSigSync, barkerSequence, M, dataLength, overlapBuffer, partialPacket)

    rxSigFrame = [];

    packetComplete = false;

    % PSK modulate barkerSequence used in transmission

    barkerSymbols = pskmod(barkerSequence, M, pi/M, 'gray');

    detector = comm.PreambleDetector(barkerSymbols.', 'Threshold', 13);

    idx = detector(rxSigSync)

    

    % Check if a preamble was detected

    if ~isempty(idx)

        dataStartIdx = idx(1) + 1; % Assuming the first detected preamble

        % Check if the complete packet is within the current buffer

        if (dataStartIdx + dataLength - 1) <= length(rxSigSync)

            % Packet can be fully extracted from the current buffer

            rxSigFrame = rxSigSync(dataStartIdx:dataStartIdx+dataLength);
            partialPacket = []; % Clear any existing partial packet
            packetComplete = true;

        else

            % Packet spans into the next buffer, extract what we can and store it
            partialPacket = rxSigSync(dataStartIdx:end);
            
            % Indicate packet is not complete
            packetComplete = false;

        end

    else

        if ~isempty(partialPacket)

            % Try to complete the packet with the current buffer

            neededLength = dataLength - length(partialPacket);

            if length(overlapBuffer) >= neededLength

                % We can now complete the packet

                rxSigFrame = [partialPacket; overlapBuffer(1:neededLength)];

                partialPacket = []; % Clear partialPacket as it's now been used

                packetComplete = true;

            else

                % Still not enough data, append and wait for more

                partialPacket = [partialPacket; overlapBuffer];

                packetComplete = false;

            end

        end

    end

end