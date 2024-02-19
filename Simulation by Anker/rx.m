%*************************************************************************
% Filename: rx.m
%
% Contents: This file contains the receiver block with all synchronizations 
% and compensations.
%*************************************************************************


function [rxSignal, frequencyOffsetEstimate] = rx(channelSignal,rollOffFactor,filterSpan,samplesPerSymbol,samplingFrequency)

    %********************************
    % Frame Synchronization     
    %********************************

    % Create a root raised cosine filter
    rootRaisedCosineFilter = rcosdesign(rollOffFactor,filterSpan,samplesPerSymbol);   
    % definedPlot(rootRaisedCosineFilter, 2, "Root Raised Cosine Filter");


    % Apply a matched filter (also RRCF) to received signal
    rxSignal_MatchedFiltered = upfirdn(channelSignal,rootRaisedCosineFilter,1,samplesPerSymbol); 
    rxSignal_MatchedFiltered = rxSignal_MatchedFiltered(samplesPerSymbol*filterSpan+1:end-(filterSpan*samplesPerSymbol-1));
    definedPlot(rxSignal_MatchedFiltered, 3, "rxSignal MatchedFiltered")
    % ^ Remove a portion of the signal? —> modulate.m
    % ^ multiply with samplesPerSymbol if still oversampled? —> modulate.m
    

    % Coarse frequency compensation
    % coarseSync = comm.CoarseFrequencyCompensator(...  
    %     'Modulation','QPSK',...
    %     'FrequencyResolution',1,...
    %     'SampleRate',samplingFrequency*samplesPerSymbol); % samplingFrequency*samplesPerSymbol if signal is still oversampled
    % [rxSigCoarse, frequencyOffsetEstimate] = coarseSync(rxSignal_MatchedFiltered);


    % Coarse phase shift compensation
    % [!] NEEDS IMPLEMENTATION


    % Fine frequency and fine phase shift compensation
    % [!] NEEDS IMPLEMENTATION




    %********************************
    % Timing Synchronization     
    %********************************

    % Timing (symbol) synchronization
    % [!] NEEDS IMPLEMENTATION


    rxSignal = rxSignal_MatchedFiltered; % <— Changes during testing
    frequencyOffsetEstimate = 0;

end