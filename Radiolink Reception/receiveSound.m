function receiveSound




clc;
disp("#############################");
disp("Audio receiver server started");
disp("#############################");
disp(" ");




% Initializations.
run('receptionParameters.m');


% Pulse shape filter object.
rootRaisedCosineFilter = rcosdesign(rollOff, filterSpan, samplesPerSymbol);


% Pluto SDR system object.
configurePlutoRadio('AD9364');
rxRadioObject = sdrrx('Pluto');
rxRadioObject.CenterFrequency = txFrequency;
rxRadioObject.BasebandSampleRate = modulationSampleRate;
rxRadioObject.SamplesPerFrame = informationDataNumberOfSamples;
rxRadioObject.OutputDataType = 'double';


% Frequency compensation object.
coarseSynchronizerObject = comm.CoarseFrequencyCompensator( ...  
    'Modulation','QPSK', ...
    'FrequencyResolution', 10, ...
    'SampleRate', modulationSampleRate ...      %Multiply by samplesPerSymbol if signal is still oversampled.
    ); 


% Symbol synchronizer object (Timing).
symbolSynchronizerObject = comm.SymbolSynchronizer(...
    'TimingErrorDetector', 'Gardner (non-data-aided)', ...
    'DampingFactor', 0.7, ...
    'NormalizedLoopBandwidth', 0.01, ...
    'SamplesPerSymbol', samplesPerSymbol ...
    ); 


% Fine frequency synchronizer and fine phase synchronizer object.
fineSynchronizerObject = comm.CarrierSynchronizer( ...
    'DampingFactor', 0.7, ...
    'NormalizedLoopBandwidth', 0.01, ...
    'SamplesPerSymbol', 1, ...
    'Modulation', 'QPSK' ...
    );




% Keep running.
counter = 0;


while true
    % Status byte is initialized to zero, so we don't think about it here.


    % Fetch Pluto SDR buffer of received signal.
    receivedData = rxRadioObject();
    disp("Packet    #" + counter + " transmission received.")


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
        barkerSequence, ...
        modulationOrder, ...
        informationDataSize, ...
        overlapBuffer, ...
        partialPacket, ...
        preambleThresholdFactor ...
        );
    
    
    % Extract packets and store to memory.
    audioDataHandler( ...
        rxSignal_Frames, ...
        rxSignal_SymbolSynchronized, ...
        packetCompletions, ...
        packetsToStore, ...
        dataStartIndexes, ...
        fineSynchronizerObject, ...
        informationDataSize, ...
        barkerSequence, ...
        modulationOrder ...
        );

    
    % Assuming 'rxData' is the raw data buffer you're processing
    % Update overlapBuffer with the last part of rxData for the next iteration
    % NOTE: Ensure 'overlapSize' is defined and initialized correctly.
    overlapBuffer = receivedData(end - overlapSize + 1:end);


    disp("Packet    #" + counter + " demodulated.")
    counter = counter + 1;
end