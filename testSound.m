pool = gcp('nocreate'); % If no pool exists, do not create a new one.
if isempty(pool)
    pool = parpool; % Create a new pool if none exists.
end

[audioDataOriginal, fss] = audioread('CantinaBand3.wav');

% Ensure audio data is mono by averaging if stereo
if size(audioDataOriginal, 2) == 2
    audioData = mean(audioDataOriginal, 2);
else
    audioData = audioDataOriginal;
end

% Convert audio data to 16-bit integers
audioData = int16(audioData * 32767); % Scale to 16-bit range if not already

% Step 2: Convert Audio Samples to Bits
audioBits = reshape(dec2bin(typecast(audioData(:), 'uint16'), 16).' - '0', 1, []);

% QPSK Modulation
M = 4; % For QPSK
symbolIndices = bi2de(reshape(audioBits, log2(M), []).', 'left-msb');
modulatedSignal = pskmod(symbolIndices, M, pi/M, 'gray');

% Simulate Transmission
receivedSignal = modulatedSignal; % This would include channel effects in a real scenario

% QPSK Demodulation
demodulatedIndices = pskdemod(receivedSignal, M, pi/M, 'gray');
receivedBits = reshape(de2bi(demodulatedIndices, log2(M), 'left-msb').', 1, []);

% Convert Bits Back to Audio Samples
receivedAudio = typecast(uint16(bin2dec(reshape(char(receivedBits + '0'), 16, []).')), 'int16');

% Convert 16-bit integer audio back to floating-point for playback
normalizedAudio = double(receivedAudio) / 32767; % Normalize to -1 to 1 range for playback

% Check for NaNs or Infs (just in case)
if any(isnan(normalizedAudio)) || any(isinf(normalizedAudio))
    error('Normalized audio contains NaNs or Infs.');
end

% Use parfeval to play audio in parallel
f = parfeval(pool, @playAudioInParallel, 0, normalizedAudio, fss); % 0 indicates no output arguments


function playAudioInParallel(audioData, fss)
    sound(audioData, fss);
end