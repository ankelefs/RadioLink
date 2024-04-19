function lostPackets = checkPacketLoss(receivedPacketNumbers)
    % Initialize lost packet count
    lostPackets = 0;
    
    % Loop through the received packets
    for i = 2:length(receivedPacketNumbers)
        % Calculate the expected next packet (increment by 1 and wrap around using modulo 256)
        expectedPacket = mod(receivedPacketNumbers(i - 1) + 1, 256);
        
        % Check if the current packet is as expected
        if receivedPacketNumbers(i) ~= expectedPacket
            % Increment the lost packet count
            if receivedPacketNumbers(i) > expectedPacket
                lostPackets = lostPackets + (receivedPacketNumbers(i) - expectedPacket);
            else
                % This handles a valid wrap-around or unexpected low number
                lostPackets = lostPackets + (256 - expectedPacket + receivedPacketNumbers(i));
            end
        end
    end
    
    % Display the total number of lost packets
    fprintf('Total Lost Packets: %d\n', lostPackets);
end
