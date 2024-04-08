function playSound




clc;
disp("###########################");
disp("Audio player server started");
disp("###########################");
disp(" ");
       



% Initializations.
run('receptionParameters.m');


% Audio player object.
playAudio = audioDeviceWriter( ...          
    "SampleRate", audioSampleRate, ...
    "BitDepth", audioBitDepthMap, ...
    "Device", "Default" ...                 % Audio output device.
    );




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
    audioRecording = memory.Data(2:end);
    memory.Data(1) = 0;
    disp("Recording #" + counter + " fetched from memory.")
    
    
    % Decode audio recording data and playback.
    audioRecording = [round((audioRecording / 128) + 1)]
    playAudio(audioRecording);
    disp("Recording... #" + counter + " played."); 
    
    
    counter = counter + 1;
end       