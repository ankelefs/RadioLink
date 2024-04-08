function dataPacket = prepareDataForTransmission(transmissionData, barkerSequence, audioBitDepth, garbageBitsArraySize)




% Create garbage bits for filter ramp up.
garbageBits = randi([0, 1], garbageBitsArraySize, 1);


% Convert transmission data in UINT8 into binary.
transmissionDataBinary = int2bit(transmissionData, audioBitDepth);


% Concatenate into a total dataPacket.
dataPacket = [garbageBits; barkerSequence; transmissionDataBinary; garbageBits];