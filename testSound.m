audioReader = audioDeviceReader('SamplesPerFrame', 4096, 'SampleRate', newFs);

while true
    audioData = audioReader();  % Read audio frame from microphone
    sound(audioData, 16000);
end