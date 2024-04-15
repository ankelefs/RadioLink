function transmitSound_filePlayback




clc;
disp("################################");
disp("Audio transmitter server started");
disp("################################");
disp(" ");




% Initializations.
run('transmissionParameters.m');


% Pulse shape filter object.
rootRaisedCosineFilter = rcosdesign(rollOff, filterSpan, samplesPerSymbol);

dataLength = 1000; % Number of symbols per packet


% Pluto SDR system object.
configurePlutoRadio('AD9364');
txRadioObject = sdrtx('Pluto');
txRadioObject.CenterFrequency = txFrequency;
txRadioObject.BasebandSampleRate = modulationSampleRate;
txRadioObject.Gain = 0;



[audioDataOriginal, fss] = audioread('CantinaBand3.wav');


% Ensure audio data is mono by averaging if stereo
if size(audioDataOriginal, 2) == 2
    audioData = mean(audioDataOriginal, 2);
else
    audioData = audioDataOriginal;
end


% Convert audio data to 8-bit integers
audioData = int8(audioData * 127); % Scale to 16-bit range if not already

% Step 2: Convert Audio Samples to Bits
audioBits = reshape(dec2bin(typecast(audioData(:), 'uint8'), 8).' - '0', 1, []);
symbolIndices = bi2de(reshape(audioBits, log2(modulationOrder), []).', 'left-msb');
numPackets = ceil(length(symbolIndices) / dataLength); % Calculate the number of packets
modulatedSymbols = []; % Initialize array to hold modulated packets

for i = 1:numPackets
    % Extract packet data
    startIdx = (i-1) * dataLength + 1;
    endIdx = min(i * dataLength, length(symbolIndices));
    packetData = symbolIndices(startIdx:endIdx);
    
        % Check if the current packet has enough data; if not, skip it
    if length(packetData) < dataLength
        % Not enough data for a full packet, skip this packet
        continue; % Skip the rest of the loop iteration
    end
    % Prepend preamble to the packet
    packet = [barkerSequence, packetData.'];
    
    % Modulate the packet (considering your M, pi/M, and 'gray' from soundParams)
    txSig = pskmod(packet, modulationOrder, pi/modulationOrder, 'gray');
    
    % Apply RRC Filter (optional, based on your requirement)
    txSigFiltered = upfirdn(txSig, rootRaisedCosineFilter, samplesPerSymbol);
    
    % Append to the overall modulated packets array
    modulatedSymbols = [modulatedSymbols; txSigFiltered.']; % Consider any required gap between packets
end


% Transmit the signal
disp('Starting transmission...');
transmitRepeat(txRadioObject, modulatedSymbols); % Continuously transmit the signal