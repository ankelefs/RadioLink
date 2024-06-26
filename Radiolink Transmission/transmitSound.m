function transmitSound




clc;
disp("################################");
disp("Audio transmitter server started");
disp("################################");
disp(" ");




% Initializations.
run('transmissionParameters.m');


% Pulse shape filter object.
rootRaisedCosineFilter = rcosdesign(rollOff, filterSpan, samplesPerSymbol);


% Pluto SDR system object.
configurePlutoRadio('AD9364');
txRadioObject = sdrtx('Pluto');
txRadioObject.CenterFrequency = txFrequency;
txRadioObject.BasebandSampleRate = modulationSampleRate;
txRadioObject.Gain = 0; 




% This code is the same for both server initiations.
if ~exist('audioRecordings.dat', 'file')
    fileID = fopen('audioRecordings.dat', 'w');
    

    % Create the shared file if it is not already there.
    if fileID ~= -1
        % Initialize memory with 1 status byte and 256 information bytes,
        % all zeros.
        fwrite(fileID, zeros([audioFrameLength + 1, 1]), audioBitDepthMap);
        fclose(fileID);
    else
        error('MATLAB:demo:answer:cannotOpenFile', ...
              'Cannot open file "%s": %s.', audioRecordings, msg);
    end
end


% Memory map the file for quick access.
memory = memmapfile('audioRecordings.dat', 'Writable', true, 'Format', 'uint8');




% Keep running.
counter = 0;


while true
    % Set status byte to zero and wait until the first byte is not zero.
    memory.Data(1) = 0;
    while memory.Data(1) == 0
        pause(1e-6);
    end


    % When status byte is not zero: fetch memory data and set status byte
    % back to zero
    transmissionData = memory.Data(2:end);
    memory.Data(1) = 0;
    disp("Recording #" + counter + " fetched from memory.")
    
    
    % Prepare data for transmission and then transmit.
    transmissionDataPacket = prepareDataForTransmission(transmissionData, barkerSequence, audioBitDepth, garbageBitsArraySize);
    transmit(transmissionDataPacket, ...
        rootRaisedCosineFilter, ...
        modulationOrder, ...
        samplesPerSymbol, ...
        txRadioObject, ...
        counter ...
        );
    
    
    counter = counter + 1;
end