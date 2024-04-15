function dataPacket = prepareDataForTransmission(soundData, barkerSymbols, garbageSymbols, modulationOrder, audioBitDepth)




% Convert transmission data in UINT8 into binary.
soundDataBinary = int2bit(soundData, audioBitDepth);


% Modulate the transmission data into symbols, using grey-coding, and concatenate 
% all transmission data into a total data packet.
transmissionDataSymbols = pskmod(soundDataBinary, modulationOrder, pi/modulationOrder, 'gray', 'InputType', 'bit');
dataPacket = [garbageSymbols; barkerSymbols; transmissionDataSymbols; garbageSymbols];