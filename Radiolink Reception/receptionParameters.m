% Pulse shape filter parameters.
rollOff = 0.5;
filterSpan = 12; 
samplesPerSymbol = 8;
modulationSampleRate = 1e6;             % Corresponds to 8 us symbol length.
modulationOrder = 4;                    % QPSK.

% Pulse shape filter object.
rootRaisedCosineFilter = rcosdesign(rollOff, filterSpan, samplesPerSymbol);




% Audio parameters.
audioFrameLength = 256;                 % Corresponds to 32 ms.
audioSampleRate = 8000; 
audioBitDepth = 8;
audioBitDepthMap = 'uint8';
audioBitDepthMap2 = '8-bit integer';
packetsToStore = 5;
packetScalingFactor = 20;
informationDataSize = audioFrameLength * audioBitDepth; 
informationDataNumberOfSamples = packetScalingFactor * informationDataSize * samplesPerSymbol; 




% Barker codes.
barkerSequence = [1, 1, 1, 1, 1, 0, 0, 1, 1, 0, 1, 0, 1]';      % Column vector.
barkerSequenceSize = length(barkerSequence);         

% Estimate and correct phase offset in the received signal frame by
% using known pilot symbols. Each Barker code element is interpreted as an
% integer/symbol.
barkerSymbols = pskmod(barkerSequence, modulationOrder, pi/modulationOrder, 'gray', 'InputType', 'integer');
numPilotSymbols = length(barkerSymbols);




% comm.-objects parameters.
frequencyResolutionFactor = 50;
dampingFactor = 0.7;
normalizedLoopBandwidthFactor = 0.04;
preambleThresholdFactor = 30;


% Frequency compensation object.
coarseSynchronizerObject = comm.CoarseFrequencyCompensator( ...  
    'Modulation','QPSK', ...
    'Algorithm', 'FFT-based', ...
    'FrequencyResolution', frequencyResolutionFactor, ...
    'SampleRate', modulationSampleRate ...      % Multiply by samplesPerSymbol if signal is still oversampled.
    ); 


% Symbol synchronizer object (Timing).
symbolSynchronizerObject = comm.SymbolSynchronizer( ...
    'Modulation', 'PAM/PSK/QAM', ...
    'TimingErrorDetector', 'Gardner (non-data-aided)', ...          % Can change to see effects?
    'SamplesPerSymbol', samplesPerSymbol, ...    
    'DampingFactor', dampingFactor, ...
    'NormalizedLoopBandwidth', normalizedLoopBandwidthFactor ...
    ); 


% Fine frequency synchronizer and fine phase synchronizer object.
fineSynchronizerObject = comm.CarrierSynchronizer( ...
    'Modulation', 'QPSK', ...
    'SamplesPerSymbol', samplesPerSymbol, ...    
    'DampingFactor', dampingFactor, ...
    'NormalizedLoopBandwidth', normalizedLoopBandwidthFactor ...
    );


% PSK modulate barker code sequence and look for a match in the received data.
preambleDetectorObject = comm.PreambleDetector( ...
    'Input', 'Symbol', ...
    'Preamble', barkerSymbols, ...
    'Threshold', preambleThresholdFactor, ...
    'Detections', 'All' ...
    );




% Define overlap size based on your preamble length and expected signal characteristics.
overlapSize = informationDataSize + barkerSequenceSize - 1; 
overlapBuffer = zeros(overlapSize, 1);
partialPacket = [];             % Initialization is crucial before its first use.




% Initialize shared memory.
% Needs to be larger than packetScalingFactor times informationDataSize due
% to overlap buffer.
memoryFileSizeScalingFactor = 10;
memoryFileSize = memoryFileSizeScalingFactor * packetScalingFactor * audioFrameLength + 1;        

% This code is the same for both server initiations.
if ~exist('audioRecordings.dat', 'file')
    fileID = fopen('audioRecordings.dat', 'w');
    

    % Create the shared file if it is not already there.
    if fileID ~= -1
        % Initialize memory with 1 status element and audioFrameLength times packetScalingFactor information bytes,
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









