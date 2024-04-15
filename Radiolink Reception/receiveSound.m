function receiveSound




clc;
disp("#############################");
disp("Audio receiver server started");
disp("#############################");
disp(" ");




% Initializations.
run('receptionParameters.m');


% SDR parameters.
txFrequency = 1.7975e9;                 % Center frequency in Hz.

% Pluto SDR system object.
configurePlutoRadio('AD9364');
rxRadioObject = sdrrx('Pluto');
rxRadioObject.CenterFrequency = txFrequency;
rxRadioObject.BasebandSampleRate = modulationSampleRate;
rxRadioObject.SamplesPerFrame = informationDataNumberOfSamples;
rxRadioObject.OutputDataType = 'double';




% Keep running.
counter = 0;


while true
    % Status byte is initialized to zero, so we don't think about it here.


    % Fetch Pluto SDR buffer of received signal.
    receivedData = rxRadioObject();
    disp("Packet    #" + counter + " received.")


    % Concatenate overlapBuffer with the current samples (receivedData).
    currentBuffer = [overlapBuffer; receivedData];


    % Demodulate and filter received data.
    % Removing a portion of the signal to account for the filter delay.
    rxSignal_Filtered = upfirdn(currentBuffer, rootRaisedCosineFilter, 1, 1);
    rxSignal_Filtered = rxSignal_Filtered(samplesPerSymbol * filterSpan + 1:end - (filterSpan * samplesPerSymbol -1)); % Multiply with the samples per symbol if signal is still oversampled.
    

    % Coarse frequency compensation.
    [rxSignal_CoarseFrequencySynchronized, frequencyOffsetEstimate] = coarseSynchronizerObject(rxSignal_Filtered);


    % Symbol synchronization (Timing).
    % Correct timing errors and downsamples by samples per symbol.
    rxSignal_SymbolSynchronized = symbolSynchronizerObject(rxSignal_CoarseFrequencySynchronized);

    
    % Frame synchronization.
    [rxSignal_Frames, partialPacket, packetCompletions, dataStartIndexes] = extractPackets( ... 
        rxSignal_SymbolSynchronized, ...
        preambleDetectorObject, ...
        informationDataSize, ...
        modulationOrder, ...
        partialPacket ...
        );
    
    
    % Extract packets and store to memory.
    audioDataPackets = audioDataHandler( ...
        rxSignal_Frames, ...
        rxSignal_SymbolSynchronized, ...
        packetCompletions, ...
        dataStartIndexes, ...
        fineSynchronizerObject, ...
        modulationOrder, ...
        barkerSymbols, ...
        numPilotSymbols, ...
        audioFrameLength, ...
        audioBitDepth, ...
        counter ...
        );

    
    % Send all the decoded data packets (audio recording) to memory 
    % [!] and set status byte to number of useful packets, if not empty.
    if ~isempty(audioDataPackets)
        numberOfExtractedPackets = length(audioDataPackets) / audioFrameLength;
    
    
        % Make sure the data size of audioDataPackets matches that of the
        % memory file (minus the one status element).
        if length(audioDataPackets) ~= memoryFileSize - 1
            % Add zeros so that the data and file sizes match.
            audioDataPackets = [audioDataPackets; zeros(memoryFileSize - length(audioDataPackets) - 1, 1)];
            disp(length(memory.Data(2:end)))
            disp(memoryFileSize - 1)
            disp(length(audioDataPackets))
        end


        memory.Data(2:end) = audioDataPackets;
        memory.Data(1) = numberOfExtractedPackets;
        disp("Packets   #" + counter + ".x stored to memory.");
    end
    

    % Assuming 'rxData' is the raw data buffer you're processing
    % Update overlapBuffer with the last part of rxData for the next iteration
    % NOTE: Ensure 'overlapSize' is defined and initialized correctly.
    overlapBuffer = receivedData(end - overlapSize + 1:end);


    counter = counter + 1;
end