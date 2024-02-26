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
    % Remove the ramp-up and ramp-down of the receive-filter
    rxSignal_MatchedFiltered = rxSignal_MatchedFiltered(filterSpan+1:end-(filterSpan));
    definedPlot(rxSignal_MatchedFiltered, 3, "rxSignal MatchedFiltered")
    

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





    % coarseSync = comm.CoarseFrequencyCompensator( ...  
    %     'Modulation','QPSK', ...
    %     'FrequencyResolution',1, ...
    %     'SampleRate',Fs*sps); %Fs*sps if signal is still oversampled
    % 
    % [rxSigCoarse, freqEstimate] = coarseSync(rxSigFiltered);
    % 
    % 
    % 
    % % Symbol Synchronizer (Timing) --------------------------------------------
    % symbolSync = comm.SymbolSynchronizer(...
    %     'TimingErrorDetector', 'Gardner (non-data-aided)', ...
    %     'DampingFactor', 0.7, ...
    %     'NormalizedLoopBandwidth', 0.01, ...
    %     'SamplesPerSymbol', sps); 
    % 
    % % Correct timing errors, downsamples by sps
    % rxSigSync = symbolSync(rxSigCoarse);
    % 
    % 
    % %----------------------------FRAME SYNC-----------------------------------
    % % PSK modulate barkerSequence used in transmission
    % barkerSymbols = pskmod(barkerSequence, M, pi/M, 'gray');
    % detector = comm.PreambleDetector(barkerSymbols.', 'Threshold', 35);
    % idx = detector(rxSigSync)
    % dataStartIdx = idx+1;
    % rxSigFrame = rxSigSync(dataStartIdx:end);
    % 
    % 
    % % Estimate phase offset --------------------------------------------------
    % % Don't use first sample as it is centered by the timing synchronizer?
    % receivedPilotSymbols = rxSigSync(dataStartIdx-length(barkerSymbols)+1:dataStartIdx-1);
    % % Modulate the known pilot sequence and upsample!!!
    % expectedPilotSymbols = pskmod(barkerSequence(2:end), M, pi/M, 'gray');
    % phaseDifferences = angle(receivedPilotSymbols.* conj(expectedPilotSymbols.'));
    % 
    % % Estimate the phase shift as the mean of the phase differences
    % estPhaseShift = mean(phaseDifferences);% Correct phase shift
    % estPhaseShiftDeg = rad2deg(estPhaseShift)
    % % Correct for phase shift
    % rxSigPhase = rxSigFrame * exp(-1i * estPhaseShift);
    % 
    % 
    % 
    % 
    % 
    % % Fine frequency sync and FINE phase sync, does not work if phase offset is
    % % outside of quadrant.
    % fineSync = comm.CarrierSynchronizer( ...
    %     'DampingFactor',0.7, ...
    %     'NormalizedLoopBandwidth',0.01, ...
    %     'SamplesPerSymbol',sps, ...
    %     'Modulation','QPSK');
    % rxSigFine = fineSync(rxSigPhase);




end