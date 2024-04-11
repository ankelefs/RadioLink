function audioDataHandler(inputSignal, packetCompletions, packetsToStore, dataStartIndex, fineSynchronizerObject)





% Initializations.
previousPhaseShift = 0;


% Initialize the buffer based on the expected size of demodulated receive data.
demodulationBuffer = zeros(informationDataSize * packetsToStore, 1);
insertIndexDemodulation = 1;    % Start index for inserting data into demodulation buffer.




% Iterate through each extracted packet.
for packetIndex = 1:length(inputSignal) 
    rxSignal_Frame = inputSignal{packetIndex};          % Extracted packet.
    packetComplete = packetCompletions(packetIndex);      % Completion status of the packet.
    dataStartIndex = dataStartIndex(packetIndex);       % Start index of the packet.
    

    % PROBLEM: partialPacket does not have index, so iteration through
    % rxSignal_Frame is not possible.


    % Only proceed with phase correction and further processing if a
    % complete packet was extracted.
    if packetComplete
        % Phase correction.
        [rxSignal_PhaseCorrected, estimatedPhaseShift, estimatedPhaseShiftDegrees] = estimatePhaseOffset( ...
            rxSignal_Frame, ...
            barkerSequence, ...
            modulationOrder, ...
            inputSignal, ...
            dataStartIndex, ...
            previousPhaseShift ...
            );
        
        
        % Fine frequency and fine phase synchronization.
        rxSignal_FineAdjusted = fineSynchronizerObject(rxSignal_PhaseCorrected);
        
        
        % Demodulate.
        rxSignal_Demodulated = pskdemod(rxSignal_FineAdjusted, modulationOrder, pi/modulationOrder, 'gray');
        
        
        % Calculate the new insert indices for the demodulated data.
        startIndex = insertIndexDemodulation;
        endIdx = insertIndexDemodulation + dataLength - 1;


        % Update the buffer with the new demodulated data
        demodBuffer(startIndex:endIdx) = rxSignal_Demodulated;


        % Update the insert index for the next batch of data
        insertIndexDemodulation = endIdx + 1;
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