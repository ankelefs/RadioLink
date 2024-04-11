   function recordSound




clc;
disp("#############################");
disp("Audio recorder server started");
disp("#############################");
disp(" ");


 

% Initializations.
run('transmissionParameters.m');


% Audio recorder object.
recordAudio = audioDeviceReader( ...
    'SampleRate', audioSampleRate, ...      
    'SamplesPerFrame', audioFrameLength * packetScalingFactor, ...
    'BitDepth', audioBitDepthMap2, ...
    'Device', 'Default' ...                 % Audio input device.
    );




% Keep running.
counter = 0;


while true
    % Status byte is initialized to zero, so we don't think about it here.
  
    
    % Wait for audio recording by key toggle.
    waitforbuttonpress;
    disp("Recording... #" + counter);
    
    
    audioRecording = recordAudio();
    % Prepare the recording for memory storage.
    % Store in memory as UINT8 from 0 to 128.
    binaryAudioData = [round((audioRecording + 1) * 128)];
    

    % Fill memory with 32 ms of audio from the function. Then set status
    % byte to one.
    memory.Data(2:end) = binaryAudioData;
    memory.Data(1) = 1;
    disp("Recording... #" + counter + " stored to memory."); 
    
    
    counter = counter + 1;
end       