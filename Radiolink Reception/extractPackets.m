function [rxSignal_Frames, partialPacket, packetCompletions, dataStartIndexes] = extractPackets( ...
    rxSignal_SymbolSynchronized, ...
    barkerSequence, ...
    modulationOrder, ...
    informationDataSize, ...
    overlapBuffer, ...
    partialPacket, ...
    preambleThresholdFactor ...
    )




% Initializations.
rxSignal_Frames = {};
packetCompletions = [];
dataStartIndexes = [];
overlapBufferLength = length(overlapBuffer) - 1;
barkerSequenceSize = length(barkerSequence);




% Check and complete any existing partial packets first.
% if ~isempty(partialPacket)
%         % Find out how much more of the packet we are expecting.
%         neededLength = overlapBufferLength + informationDataSize - length(partialPacket) - 1;
% 
%         % Directly complete the packet with the beginning of input signal.
%         rxSignal_Frame = [partialPacket; rxSignal_SymbolSynchronized(overlapBufferLength:neededLength)];
%         rxSignal_Frames{end + 1} = rxSignal_Frame;
% 
%         % Clear the partial packet and append the 'true'-value.
%         partialPacket = [];                             
%         packetCompletions(end + 1) = true;
% 
%         % NOTE: The data will include Barker codes for partial packets.
%         dataStartIndexes(end + 1) = 1;                    
% end


% PSK modulate barker code sequence and look for a match in the received data.
barkerSymbols = pskmod(barkerSequence, modulationOrder, pi/modulationOrder, 'gray', 'InputType', 'bit');
preambleDetectorObject = comm.PreambleDetector(barkerSymbols, 'Threshold', preambleThresholdFactor, 'Detections', 'All');
preambleDetectorIndexes = preambleDetectorObject(rxSignal_SymbolSynchronized)


% Track start index of last detected packet.
lastDataStartIndex = 0; 


for i = 1:length(preambleDetectorIndexes)
    dataStartIndex = preambleDetectorIndexes(i) + 1;


    % Skip the preamble if it is too close to a different one.
    if (dataStartIndex - lastDataStartIndex) < 50
        continue; 
    end


    % Check if packet can be fully extracted from the current buffer.
    if (dataStartIndex + informationDataSize - 1) <= length(rxSignal_SymbolSynchronized)
        lastDataStartIndex = dataStartIndex;
        rxSignal_Frame = rxSignal_SymbolSynchronized(dataStartIndex:dataStartIndex + informationDataSize -1);
        rxSignal_Frames{end + 1} = rxSignal_Frame;
        packetCompletions(end + 1) = true;
        dataStartIndexes(end + 1) = dataStartIndex;
    else
        % Packet spans into the next buffer, store the partial part.
        % NOTE: Assume only one packet can span buffers at a time
        % For a partial packet we also include the Barker sequence so we
        % can estimate the phase.
        % partialPacket = inputSignal(dataStartIdx:end); % NOTE: This is handled by the overlap buffer.
        break;
    end
end
