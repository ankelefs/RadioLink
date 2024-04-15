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
    "BitDepth", audioBitDepthMap2, ...
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
  
    
    % When status byte is not zero: fetch needed memory data and set status byte
    % back to zero
    numberOfSoundPackets = memory.Data(1);
    audioRecording = memory.Data(2:numberOfSoundPackets * audioFrameLength);
    memory.Data(1) = 0;
    disp("Packet #" + counter + " fetched from memory.")
    disp("Packet #" + counter + " has " + numberOfSoundPackets + " audio frames.")
    
    
    % Decode audio recording data and playback.
    audioRecording = [round((audioRecording / 128) + 1)];
    playAudio(audioRecording);
    disp("Packet #" + counter + "... played."); 
    
    
    counter = counter + 1;
end       