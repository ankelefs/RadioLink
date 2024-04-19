% Include necessary libraries and setup parameters
run('soundParams.m');

% Setup audio capture
audioReader = audioDeviceReader('SamplesPerFrame', 2000, 'SampleRate', newFs);

% Setup PlutoSDR transmitter
tx = sdrtx('Pluto');
tx.CenterFrequency = fc;
tx.BasebandSampleRate = fs;
tx.Gain = 0;

% Initialize packet number
packetNumber = 0;

% Process and transmit in a loop
disp('Starting transmission...');
while true
    % Step 1: Capture audio data
    audioData = audioReader();  % Read audio frame from microphone

    % Step 2: Convert audio data to 16-bit integers
    audioData = int16(audioData * 32767); % Scale to 16-bit range

    % Step 3: Convert Audio Samples to Bits
    audioBits = reshape(dec2bin(typecast(audioData(:), 'uint16'), 16).' - '0', 1, []);
    symbolIndices = bi2de(reshape(audioBits, log2(M), []).', 'left-msb');

    % Calculate the number of packets
    numPackets = ceil(length(symbolIndices) / dataLength);
    modulatedSymbols = [];

    for i = 1:numPackets
        % Extract packet data
        startIdx = (i-1) * dataLength + 1;
        endIdx = min(i * dataLength, length(symbolIndices));
        packetData = symbolIndices(startIdx:endIdx);

        % Check if the current packet has enough data; if not, skip it
        if length(packetData) < dataLength
            continue; % Skip the rest of the loop iteration
        end

        % Encode packet number as 4-symbol header
        packetHeader = de2bi(mod(packetNumber, 256), headerLength*2, 'left-msb');
        packetNumber = mod(packetNumber + 1, 256);  % Increment and wrap around packet number

        % Prepend preamble and header to the packet
        packet = [packetHeader, barkerSequence, packetData.'];

        % Modulate the packet
        txSig = pskmod(packet, M, pi/M, 'gray');

        % Apply RRC Filter (optional)
        txSigFiltered = upfirdn(txSig, rrcFilter, sps);

        % Append to the overall modulated packets array
        modulatedSymbols = [modulatedSymbols; txSigFiltered.']; % Consider any required gap between packets
    end

    % Transmit the buffered signal
    tx(modulatedSymbols); % Continuously transmit the buffered signal
end
