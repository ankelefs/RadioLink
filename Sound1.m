recObj = audiorecorder;

fprintf('Audio Recorder Properties:\n');
fprintf('SampleRate: %d\n', recObj.SampleRate);
fprintf('BitsPerSample: %d\n', recObj.BitsPerSample);
fprintf('NumChannels: %d\n', recObj.NumChannels);
fprintf('DeviceID: %d\n', recObj.DeviceID);

% Set the key to trigger recording
startStopKey = 'k';
termKey = 't';

% Variable to track recording state
isRecording = false;

fprintf('Press "%s" to toggle recording. Press "%t" to stop the program.\n', startStopKey);

while true
    % Wait for the key press
    keyPress = waitForKeyPress;
    
    if isequal(keyPress, termKey)
        % If Enter is pressed, exit the loop and stop the program
        fprintf('Enter key pressed. Stopping the program.\n');
        break;
    elseif isequal(keyPress, startStopKey)
        if isRecording
            % Stop recording
            stop(recObj);
            fprintf('Recording stopped.\n');
        else
            % Start recording
            record(recObj);
            fprintf('Recording started.\n');
        end
        
        % Toggle recording state
        isRecording = ~isRecording;
    end
end

% To retrieve the recorded audio data
audioData = getaudiodata(recObj);


% Play the recorded audio
fprintf('Playing the recorded audio.\n');
play(recObj);

% If you want to play the audio data directly without using the recorder object
% sound(audioData, recObj.SampleRate);

% Function to wait for a key press
function keyPress = waitForKeyPress
    w = waitforbuttonpress;
    if w
        keyPress = get(gcf, 'CurrentCharacter');
    else
        keyPress = [];
    end
end

