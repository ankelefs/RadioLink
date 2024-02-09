%*************************************************************************
% Filename: parameters.m
%
% Contents: This file stores and initializes all relevant parameters.
%*************************************************************************

% Mapping from bits to symbols following QPSK scheme using Gray-coding. 
% Each complex amplitude is given as A + iB. A: In-phase, B: Quadrature.
% A = 1 / sqrt(2);
% B = 1i * (1 / sqrt(2));
% keys = ["zz" "zo" "oz" "oo"];
% values = [-A+B A+B -A-B A-B];
% 
% bitsToSymbolsMapping = dictionary(keys, values);
% MSymbols = length(keys);
NBitsPerSymbol = 2;
MSymbols = 2^NBitsPerSymbol;


% Tx signal
upsampleFactor = 3;


% Root Raised Cosine Tx Filter
rollOffFactor = 0.5;                            % Roll-off factor.
filterSpan = 15;                          
samplesPerSymbol = 4;   
% Notice:
% The product of filterSpan and samplesPerSymbol must be an even number for 
% the filter to work.