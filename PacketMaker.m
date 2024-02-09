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


