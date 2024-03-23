run('textParams.m');

message = 'Hello world, Da krydrær vi med litt prostatakreft på toppen';
messageBin = text2bin(message);
% Initialize an array to hold the symbols
symbols = zeros(1, numel(messageBin)/2);

% Iterate through the binary vector two elements at a time
for i = 1:2:numel(messageBin)-1
    % Extract each pair of bits as numeric values
    bit1 = messageBin(i);
    bit2 = messageBin(i+1);

    % Calculate the symbol based on the pair of bits
    % Since bits are 0 or 1, the calculation below maps directly to symbols 0-3
    symbol = bit1 * 2 + bit2;

    % Assign the calculated symbol to the symbols array
    symbols((i + 1) / 2) = symbol;
end

numPackets = ceil(length(symbols) / dataLength); % Calculate the number of packets
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



