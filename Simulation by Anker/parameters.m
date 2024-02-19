%*************************************************************************
% Filename: parameters.m
%
% Contents: This file contains all the parameters for Tx, channel and Rx.
%*************************************************************************


% Data
bits = 1000+1;
bitsPerSymbol = 2;
numberOfSymbols = 2^bitsPerSymbol;


% Signal
samplingFrequency = 1e6; 


% Root Raised Cosine Filter
rollOffFactor = 0.5;  
filterSpan = 15;                          
samplesPerSymbol = 4;  
