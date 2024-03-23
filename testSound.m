% Load the audio file
[audioDataOriginal, fss] = audioread('quack.wav');

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

% Play the normalized audio
sound(normalizedAudio, fss);

% Debugging: Plot Original vs. Received Audio
figure;
subplot(2,1,1);
plot(audioDataOriginal(1:1000));
title('Original Audio');
subplot(2,1,2);
plot(normalizedAudio(1:1000));
title('Received Audio');
