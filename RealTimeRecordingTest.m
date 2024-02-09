% Set recording parameters
Fs = 44100;                 % Sample rate (Hz)
recordDuration = 5;         % Recording duration in seconds

% Create audiorecorder object
recObj = audiorecorder(Fs, 16, 1); % 16-bit resolution, 1 channel

% Start recording
record(recObj);

% Preallocate buffer for playback
playerBufferSize = Fs * 0.05;  % Playback buffer size (0.05 second)
audioDataBuffer = zeros(playerBufferSize, 1);

% Create audioplayer object
playerObj = audioplayer(audioDataBuffer, Fs); % Initialize with empty buffer

% Start playback
play(playerObj);

% Loop until recording is complete
while isrecording(recObj)
    % Check if new data is available
    if recObj.TotalSamples > playerObj.CurrentSample
        % Get newly recorded audio data
        audioData = getaudiodata(recObj);
        
        % Update audioplayer buffer with new data
        audioDataBuffer = audioData(max(1, end-playerBufferSize+1):end);
        playerObj = audioplayer(audioDataBuffer, Fs);
        
        % Play the new audio data
        playblocking(playerObj); % Use playblocking for smoother playback
    end
    pause(0.05); % Pause to reduce loop frequency
end

% Stop recording
stop(recObj);



