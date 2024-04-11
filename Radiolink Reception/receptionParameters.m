% Parameters.
audioFrameLength = 256;                 % Corresponds to 32 ms.
audioSampleRate = 8000; 
audioBitDepth = 8;
audioBitDepthMap = 'uint8';
audioBitDepthMap2 = '8-bit integer';
packetsToStore = 5;


modulationSampleRate = 1e6;             % Corresponds to 8 us symbol length.
txFrequency = 1.7975e9;                 % Center frequency in Hz.
modulationOrder = 4;                    % QPSK.


%barkerCode = [1, 1, 1, 1, 1, 0, 0, 1, 1, 0, 1, 0, 1]';  % Column vector.
barkerSequence = [1, 1, 0, 1]';
%barkerSequence = [barkerCode; barkerCode];              % Twice a single 13-bit Barker code.
barkerSequenceSize = length(barkerSequence);         
%garbageBitsArraySize = 4;


rollOff = 0.5;
filterSpan = 12; 
samplesPerSymbol = 8;


packetScalingFactor = 20;
informationDataSize = (audioFrameLength * audioBitDepth); 
informationDataNumberOfSamples = packetScalingFactor * informationDataSize * samplesPerSymbol; 


% Define overlap size based on your preamble length and expected signal characteristics.
overlapSize = informationDataSize + barkerSequenceSize - 1; 
overlapBuffer = zeros(overlapSize, 1);
partialPacket = [];             % Initialization is crucial before its first use.
preambleThresholdFactor = 7;


memoryFileSize = packetScalingFactor * audioFrameLength + 1;




% Initialize shared memory.
% This code is the same for both server initiations.
if ~exist('audioRecordings.dat', 'file')
    fileID = fopen('audioRecordings.dat', 'w');
    

    % Create the shared file if it is not already there.
    if fileID ~= -1
        % Initialize memory with 1 status byte and audioFrameLength times packetScalingFactor information bytes,
        % all zeros.
        fwrite(fileID, zeros(memoryFileSize, 1), audioBitDepthMap);
        fclose(fileID);
    else
        error('MATLAB:demo:answer:cannotOpenFile', ...
              'Cannot open file "%s": %s.', audioRecordings, msg);
    end 
end


% Memory map the file for quick access.
memory = memmapfile('audioRecordings.dat', 'Writable', true, 'Format', 'uint8');