% Text message
text = 'Hello World!';
% Convert text to ASCII values, then to binary
binaryData = reshape(dec2bin(text, 8).' - '0', [], 1);

% Repeat the message to match desired data length
numRepeats = ceil(10000 / length(binaryData));
binaryDataRepeated = repmat(binaryData, numRepeats, 1);

% Trim or pad the data to ensure it fits exactly into the QPSK symbol stream
binaryDataRepeated = binaryDataRepeated(1:10000*2); % 2 bits per QPSK symbol
if mod(length(binaryDataRepeated), 2) ~= 0
    binaryDataRepeated = [binaryDataRepeated; 0]; % Pad with zero if necessary
end

% Convert binary pairs to decimal values for QPSK modulation
data = bi2de(reshape(binaryDataRepeated, 2, []).', 'left-msb');