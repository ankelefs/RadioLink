%*************************************************************************
% Filename: transmitMessage.m
%
% Contents: This file contains the message (data) to be transmitted.
%*************************************************************************


% Information data
data = randi([0,1],bits,1);                                     % Array must be a column vector.


% Barker code sequence
barkerCode = [1, 1, 1, 1, 1, 0, 0, 1, 1, 0, 1, 0, 1]';          % Barker code of length 13


% Combined data packet
dataPacket = [barkerCode; data];                                % Concatenate with random data
