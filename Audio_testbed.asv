%Length of each frame of recording
frameLength = 128; %Corresponds to 20 ms
Fs = 10240; % Sample rate for input
bitDepth = '16-bit integer'; %For some reason it dose not work with 8-bit
%but this is handled in the while loop below


%deviceReader lets me record audio from my microphone
audioReader = audioDeviceReader( ...
    'SampleRate', Fs, ...          % Sample rate in Hz
    'SamplesPerFrame', frameLength, ...      % Number of samples per frame
    'BitDepth', bitDepth, ...
    'Device', 'Primary Sound Capture Driver' ... % Name of the audio input device (optional)
);

%deviceWriter writes the signal to a file
fileWriter = dsp.AudioFileWriter(SampleRate= Fs);

tic
while toc<5 % In real implementation make this infinit/ end on condition
    mySignal = audioReader(); %Getting frame data
    mySignal = round((mySignal+1)*128); %converting frame data to 8-bit ints
    binaryData = dec2bin(mySignal,8); %Converting ints to binary
end
disp("End Signal Input")

release(audioReader)
release(fileWriter)

%--------------------------------------------------------------------------

% % Code to reverse bit convertion to audio again, but you will have to store
% % the full singnal in a vector outBin
% ResAudio = bin2dec(outBin);
% resAudioMat = ((ResAudio/128)-1);
% 
% %Plots signal before and after convertion/reconvertion to bits, you have to
% %make the output vector for the signal before converting to se difference
% figure(1);
% subplot(2,1,1)
% plot(output);
% 
% subplot(2,1,2);
% plot(resAudioMat);

%--------------------------------------------------------------------------

% This lets you write to output device to listen to audio
% deviceWriter = audioDeviceWriter( ...
%     'SampleRate',fileReader.SampleRate);

%Have not found a way to listen to the recording as it is recorded, but
%think this will work when we send the data and run it on two machines


