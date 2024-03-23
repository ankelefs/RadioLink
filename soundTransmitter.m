run('soundParams.m');

% Convert audio data to 16-bit integers
audioData = int16(audioData * 32767); % Scale to 16-bit range if not already

% Step 2: Convert Audio Samples to Bits
audioBits = reshape(dec2bin(typecast(audioData(:), 'uint16'), 16).' - '0', 1, []);
symbolIndices = bi2de(reshape(audioBits, log2(M), []).', 'left-msb');
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
    txSig = pskmod(packet, M, pi/M, 'gray');
    
    % Apply RRC Filter (optional, based on your requirement)
    txSigFiltered = upfirdn(txSig, rrcFilter, sps);
    
    % Append to the overall modulated packets array
    modulatedSymbols = [modulatedSymbols; txSigFiltered.']; % Consider any required gap between packets
end

% Setup PlutoSDR System object
tx = sdrtx('Pluto');
tx.CenterFrequency = fc;
tx.BasebandSampleRate = fs;
tx.Gain = 0; 




% Transmit the signal
disp('Starting transmission...');
transmitRepeat(tx, modulatedSymbols); % Continuously transmit the signal



