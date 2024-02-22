%Goal is to make real time packets of information

% Set recording parameters
Fs = 4000;  % Sample rate (Hz)
recordDuration = 10*(1/4000);  % Recording duration in seconds (100ms)
numChannels = 1;  % Number of audio channels

% Create audiorecorder object with specified parameters
BitDepth = 8;
recObj = audiorecorder(Fs, BitDepth, numChannels);

fprintf('Audio Recorder Properties:\n');
fprintf('SampleRate: %d\n', recObj.SampleRate);
fprintf('BitsPerSample: %d\n', recObj.BitsPerSample);
fprintf('NumChannels: %d\n', recObj.NumChannels);

% Record audio for (1/44100)*n samples
recordblocking(recObj, recordDuration);


% Retrieve the recorded audio data
%audioData = getaudiodata(recObj);
audioData = [-0.4, 0.2, 0.3, 0.4, 1];
disp(audioData);
audioDatacon = round((audioData+1)*128);
disp(audioDatacon);
% Convert audio samples to binary
binaryData = dec2bin(audioDatacon,BitDepth);
disp(binaryData);

%Packet parameters

for index = 1 : 1 : PacketSize
   ;
end


%Creates a scope to se the sound real time
% scope = timescope( ...
%     'SampleRate',fileReader.SampleRate, ...
%     'TimeSpan',2, ...
%     'BufferLength',fileReader.SampleRate*2*2, ...
%     'YLimits',[-1,1], ...
%     'TimeSpanOverrunAction',"Scroll");

%Look at code below to compress signal
%-------------------------------
% %%%%%%%%%%%%%TASK 1%%%%%%%%%%%%%%%%
% [x,fs]=audioread('sample.wav');
% N=length(x);
% vlcplayer=audioplayer(x,fs);
% vlcplayer.play
% %%%%%%%%%%%% task 2%%%%%%%%%%%
% t=fft(x,N);
% X=fftshift(t)
% f=-fs/2:fs/N:(fs/2-fs/N);
% figure(1)
% plot(f,abs(X))
% title('original audio signal')
% %%%%%%%%%%%%%% TASK 2 AND 4%%%%%%%%%
% Xr=zeros(1,N);
% Xr((N/4)+1:(3*N/4))= X((N/4)+1:(3*N/4));   %%FORMULA
% figure(2)
% plot(f, abs((Xr)));
% xr= real(ifft(fftshift(Xr))); %%reconstruction
% audiowrite('50% compressed.wav',xr,fs);
% title('50% compressed audio')
% xlabel('freq(hq)');ylabel('magnitude');
% %%change ratio to 60,70,80,90,95% compression ....just change FORMULA
% %Xr((N*((60/100)/2))+1 : N*(1-(60/100)/2)) = X((N*((60/100)/2))+1 :  N*(1-(60/100)/2));

%Length of each frame of recording
frameLength = 128;
Fs = 10240; % Sample rate for input
bitDepth = '16-bit integer';
% output = [];
% outBin = [];


%deviceReader lets me record audio from my microphone
audioReader = audioDeviceReader( ...
    'SampleRate', Fs, ...          % Sample rate in Hz
    'SamplesPerFrame', frameLength, ...      % Number of samples per frame
    'BitDepth', bitDepth, ...
    'Device', 'Primary Sound Capture Driver' ... % Name of the audio input device (optional)
);

%deviceWriter writes the signal to a file
fileWriter = dsp.AudioFileWriter(SampleRate= Fs);

% counter = 0;
tic
while toc<5
%     counter = counter +1;
    mySignal = audioReader(); %Getting frame data
    %mySignal= mySignal(1:Cfactor:end); %Lossy compression? Delets samples
%     output = [output;mySignal]; %For testing full signal

    mySignal = round((mySignal+1)*128);
    binaryData = dec2bin(mySignal,8);
    

%     outBin = [outBin;binaryData];
%     if counter == 100
%     disp(binaryData);
%     end


end
disp("End Signal Input")

ResAudio = bin2dec(outBin);
resAudioMat = ((ResAudio/128)-1);

figure(1);
subplot(2,1,1)
plot(output);

subplot(2,1,2);
plot(resAudioMat);

release(audioReader)
release(fileWriter)

% This lets you write to output device to listen to audio
% deviceWriter = audioDeviceWriter( ...
%     'SampleRate',fileReader.SampleRate);