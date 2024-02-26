%Length of each frame of recording
frameLength = 20; %Corresponds to 20 ms
Fs = 10000; % Sample rate for input
bitDepth = '16-bit integer'; %For some reason it dose not work with 8-bit
%but this is handled in the while loop below


%Reads from a file
fileReader = dsp.AudioFileReader( ...
    'Counting-16-44p1-mono-15secs.wav', ...
    'SamplesPerFrame',frameLength);
deviceWriter = audioDeviceWriter( ...
    'SampleRate',fileReader.SampleRate);

%deviceWriter writes the signal to a file
fileWriter = dsp.AudioFileWriter(SampleRate= Fs);

HeaderCounter = 0;
tic
toc
while ~isDone(fileReader) 
    mySignal = fileReader(); %Getting frame data
    mySignal = [round((mySignal+1)*128);HeaderCounter]; %converting frame data to 8-bit ints
    binaryData = dec2bin(mySignal,8); %Converting ints to binary
    HeaderCounter = HeaderCounter +1;
    deviceWriter((bin2dec((binaryData(1:frameLength,:)))/128)-1);
    if HeaderCounter == 63
        HeaderCounter = 0;
    end
end
disp("End Signal Input")

release(fileReader)
release(deviceWriter)
%transmitRepeat(tx,wave) %can be used to to test audio sending and
%reconstruction
%--------------------------------------------------------------------------

% % Code to reverse bit convertion to audio again, but you will have to store
% % the full singnal in a vector outBin
%Reciver chain:
% tic
% while toc <5
% [ResAudio,Header] = deal(bin2dec((binaryData(1:frameLength,:))),bin2dec((binaryData(frameLength+1,:))));
% resAudioMat = ((ResAudio/128)-1);
% end

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