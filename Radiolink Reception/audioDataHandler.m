function audioDataHandler( ...
    rxSignal_Frames, ...
    rxSignal_SymbolSynchronized, ...
    packetCompletions, ...
    packetsToStore, ...
    dataStartIndexes, ...
    fineSynchronizerObject, ...
    informationDataSize, ...
    barkerSequence, ...
    modulationOrder ...
    )





% Initializations.
previousPhaseShift = 0;


% Initialize the buffer based on the expected size of demodulated receive data.
demodulationBuffer = zeros(informationDataSize * packetsToStore, 1);
insertIndexDemodulation = 1;    % Start index for inserting data into demodulation buffer.




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
            barkerSequence, ...
            modulationOrder, ...
            dataStartIndex, ...
            previousPhaseShift ...
            );
        
        
        % Fine frequency and fine phase synchronization.
        rxSignal_FineAdjusted = fineSynchronizerObject(rxSignal_PhaseCorrected);
        
        
        % Demodulate.
        rxSignal_Demodulated = pskdemod(rxSignal_FineAdjusted, modulationOrder, pi/modulationOrder, 'gray', 'OutputType', 'bit');
        
        
        % Calculate the new insert indices for the demodulated data.
        startIndex = insertIndexDemodulation;
        endIndex = insertIndexDemodulation + dataLength - 1;


        % Update the buffer with the new demodulated data
        demodulationBuffer(startIndex:endIndex) = rxSignal_Demodulated;


        % Update the insert index for the next batch of data
        insertIndexDemodulation = endIndex + 1;
        packetCounter = packetCounter + 1;


        if packetCounter == packetsToStore
            % Send the demodulated data (audio recording) to memory and set status
            % byte to one.
            memory.Data(2:end) = audioRecording;
            memory.Data(1) = 1;
            disp("Recording #" + counter + " stored to memory.") 

                
            % Reset the dynamic parameters.
            demodulationBuffer = zeros(dataLength * packetsToStore, 1);
            packetCounter = 0;
            insertIndexDemodulation = 1;
        end
    end  
end