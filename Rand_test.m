% Recording 100ms of audio and displaying the data

% Set recording parameters
Fs = 4000;  % Sample rate (Hz)
recordDuration = 3;  % Recording duration in seconds (100ms)
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
audioData = getaudiodata(recObj);
%audioData = [-0.4, 0.2, 0.3, 0.4, 1];
disp(audioData);
audioDatacon = round((audioData+1)*128);
%disp(audioDatacon);
% Convert audio samples to binary
binaryData = dec2bin(audioDatacon,BitDepth);

%--------------------------------------------------------------------------

% Plot audio waveform in real-time
% Create figure for real-time plotting
% figure(2);
% xlabel('Time (s)');
% ylabel('Amplitude');
% title('Real-time Audio Waveform');
% ylim([-1, 1]);  % Adjust the y-axis limits as needed

% Record audio for the specified duration
record(recObj);

% Plot audio waveform in real-time
% t = [];
% audioData = [];
% while recObj.Running
%     % Check if there's new data
%     if recObj.TotalSamples > numel(audioData)
%         % Get the latest audio data
%         audioData = getaudiodata(recObj);
%         
%         % Update the time vector
%         t = (0:length(audioData)-1) / Fs;  % Time vector
%         
%         % Update the plot
%         plot(t, audioData);
%         xlim([0, recordDuration]);  % Adjust x-axis limits as needed
%         drawnow limitrate;                    % Update the plot
%         
%         % Check if recording duration has reached
%         if recObj.TotalSamples >= recordDuration*Fs
%             break;
%         end
%     end
% end
% 
% % Stop recording
% stop(recObj);

%--------------------------------------------------------------------------

% Display the binary data
disp(binaryData);

%--------------------------------------------------------------------------
%converting audio back

ResAudio = bin2dec(binaryData);
%disp(ResAudio);
resAudioMat = ((ResAudio/128)-1);
%disp(resAudioMat);

% Plot the recorded data as a vector
figure(1);
subplot(2,1,1);
plot(audioData);
title('Recorded Audio Data');
xlabel('Sample Index');
ylabel('Amplitude');
grid on;


figure(1);
subplot(2,1,2);
plot(audioData);
title('recived Audio Data');
xlabel('Sample Index');
ylabel('Amplitude');
grid on;
disp('Recording and plotting complete.');

sound(resAudioMat, Fs);