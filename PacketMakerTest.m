%Audio script for packets

Fs = 4000;
n = 1000; %Number of samples beeing recorded in total
recDur = n*(1/4000); % determening recording duration
BDepth = 8; %Spesifying the bit-depth of the audio

buffer = [];
ROB = audiorecorder(Fs,BDepth,1);
I = 0;
record(ROB);
pause(0.1);
latestSample = getaudiodata(ROB, 'uint8');
disp(latestSample);
pause(0.1);
disp(latestSample);
% while isrecording(ROB)
%     I = I + 1;
%     % Get the latest audio sample from the recorder
%     latestSample = getaudiodata(ROB, 'uint8'); % Assuming 8-bit audio data
%     % Append the latest sample to the buffer
%    
%     % Process the latest sample as needed
%     % Display the latest sample and the iteration index
%     disp(['Latest audio sample: ', num2str(latestSample), ', Iteration: ', num2str(I)]);
if KeyPress('k') %Stops the recording if the button k is pressed
    stop(ROB);
end
%end

disp(Data);


%--------------------------------------------------------------------------

%Function for circular buffer
function buffer = circularBuffer(inputSample, buffer)
    % Append the new sample to the buffer
    buffer = [buffer(2:end), inputSample];
end

%Function for detecting button press
function keyPressed = KeyPress(k)
    % Display a prompt
    disp(['Press the key "', k, '"...']);

    % Create a figure window
    fig = figure(78);

    % Wait for a key press
    waitfor(fig, 'CurrentKey', k);

    % Check if the desired key was pressed
    if strcmp(get(fig, 'CurrentKey'), k)
        disp(['The key "', k, '" was pressed.']);
        keyPressed = true;
    else
        disp(['A different key was pressed.']);
        keyPressed = false;
    end

    % Close the figure window
    close(fig);
end