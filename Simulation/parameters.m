%*************************************************************************
% Filename: parameters.m
%
% Contents: This file contains all the parameters for Tx, channel and Rx.
%*************************************************************************


% Data
bits = 1E4;
bitsPerSymbol = 2;
numberOfSymbols = 2^bitsPerSymbol;


% Signal
samplingFrequency = 61.44E6;    % MSPS from the Adalm-Pluto's datasheet


% Root Raised Cosine Filter
rollOffFactor = 0.5;  
filterSpan = 40;                          
samplesPerSymbol = 100;  
