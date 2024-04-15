% Parameters.
audioFrameLength = 256;                 % Corresponds to 32 ms.
audioSampleRate = 8000; 
audioBitDepth = 8;
audioBitDepthMap = 'uint8';
audioBitDepthMap2 = '8-bit integer';


modulationSampleRate = 1e6;             % Corresponds to 8 us symbol length.
txFrequency = 1.7975e9;                 % Center frequency in Hz.
modulationOrder = 4;                    % QPSK.


barkerCode = [1, 1, 1, 1, 1, 0, 0, 1, 1, 0, 1, 0, 1]';  % Column vector.
barkerSequence = barkerCode;
% Create the symbol representation of the Barker code interpreting each
% element as an integer/symbol.
barkerSymbols = pskmod(barkerSequence, modulationOrder, pi/modulationOrder, 'gray', 'InputType', 'integer');


% Create garbage bits for filter ramp up.
garbageBits = [1, 0, 0, 1, 1, 0, 0, 0]';
% Create the symbol representation of the garbage bits.
garbageSymbols = pskmod(garbageBits, modulationOrder, pi/modulationOrder, 'gray', 'InputType', 'bit');


rollOff = 0.5;
filterSpan = 12; 
samplesPerSymbol = 8;


packetScalingFactor = 1;                % Number of 32 ms audio packets.


memoryFileSize = packetScalingFactor * audioFrameLength + 1;




% Initialize shared memory.
% This code is the same for both server initiations.
if ~exist('audioRecordings.dat', 'file')
    fileID = fopen('audioRecordings.dat', 'w');
    

    % Create the shared file if it is not already there.
    if fileID ~= -1
        % Initialize memory with 1 status element and audioFrameLength times packetScalingFactor information elements,
        % all zeros.
        fwrite(fileID, zeros(memoryFileSize, 1), audioBitDepthMap);
        fclose(fileID);
    else
        error('MATLAB:demo:answer:cannotOpenFile', ...
              'Cannot open file "%s": %s.', audioRecordings, msg);
    end 
end


% Memory map the file for quick access.
memory = memmapfile('audioRecordings.dat', 'Writable', true, 'Format', audioBitDepthMap);