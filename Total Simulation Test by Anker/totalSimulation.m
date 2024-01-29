%*************************************************************************
% filename: totalSimulation.m
%
% contents: This file follows the hands-on course and tries to create a
% total simulated simulation protocol using BPSK that can then be implemented 
% on the Adalm-Pluto SDR.
%*************************************************************************



% PARAMETERS
%*************************************************************************
sampleRate = 44100;                 % Audio sample rate [Hz].
adalmPlutoChipset = 'AD9364';       % The chosen chipset with LO tuning BW 70-6000 MHz and 56 MHz BW.



% MAIN
%*************************************************************************
% Define a test binary signal sequence and convert to bipolar format
binarySignalArray = [1, 0, 0, 1, 1, 1, 0, 1, 0, 1];
disp(binarySignalArray);
bipolarSignalArray = binaryToBipolarFormat(binarySignalArray);
disp(bipolarSignalArray);


% Setup of Adalm-Pluto SDR
connectionStatus = configurePlutoRadio(adalmPlutoChipset);
if connectionStatus == 1
    disp("Succesful connection to Adalm-Pluto SDR.");
else
    disp("Adalm-Pluto connection failed.")
end






% FUNCTIONS 
%*************************************************************************
% Changes the input array of 1s and 0s to 1s and -1s.
function [y] = binaryToBipolarFormat(x)
    y = 2.*x - 1;
end