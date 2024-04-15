function transmitSound




clc;
disp("################################");
disp("Audio transmitter server started");
disp("################################");
disp(" ");




% Initializations.
run('transmissionParameters.m');
[audioDataOriginal, fss] = audioread('CantinaBand3.wav');


% Pulse shape filter object.
rootRaisedCosineFilter = rcosdesign(rollOff, filterSpan, samplesPerSymbol);


% Pluto SDR system object.
configurePlutoRadio('AD9364');
txRadioObject = sdrtx('Pluto');
txRadioObject.CenterFrequency = txFrequency;
txRadioObject.BasebandSampleRate = modulationSampleRate;
txRadioObject.Gain = 0; 




% Keep running.
counter = 0;


while true
    % Set status byte to zero and wait until the first byte is not zero.
    memory.Data(1) = 0;
    while memory.Data(1) == 0
        pause(1e-6);
    end


    % When status element is not zero: fetch memory data and set status
    % element back to zero
    soundData = memory.Data(2:end);
    memory.Data(1) = 0;
    disp("Recording #" + counter + " fetched from memory.")
    
    
    % Prepare data for transmission and then transmit.
    txSignal = prepareDataForTransmission(soundData, barkerSymbols, garbageSymbols, modulationOrder, audioBitDepth);
    transmit( ...
        txSignal, ...
        rootRaisedCosineFilter, ...
        samplesPerSymbol, ...
        txRadioObject, ...
        counter ...
        );
    
    
    counter = counter + 1;
end