% This file contains functions that are not in use, but may be handy to
% have in backup.

TxSignal_QPSKUpsampled = upsample(txSignal_QPSK,10);   % Adds #upsampleFactor zeros in between each complex amplitude.


function [rxSignal_FrequencyCompensated, frequencyOffsetEstimate] = coarseFrequencyCompensation(rxSig,samplingFrequency,M,Nsamples)
    % Ensure Nsamples does not exceed the length of rxSig
    Nsamples = min(Nsamples, length(rxSig));

    % Take the first Nsamples of the received signal for offset estimation
    rxSigSubset = rxSig(1:Nsamples);

    % FFT of the subset
    Nfft = 2^nextpow2(length(rxSigSubset)); % Use a power of 2 for FFT efficiency
    fftRxSigSubset = fft(rxSigSubset.^M, Nfft);
    fftMagSubset = abs(fftRxSigSubset);

    % Find the peak in the spectrum of the subset
    [~, peakIndex] = max(fftMagSubset);

    % Adjust peak index if necessary
    if peakIndex > Nfft/2
        peakIndex = peakIndex - Nfft;
    end

    % Calculate the frequency offset estimate
    frequencyOffsetEstimate = ((peakIndex-1)*samplingFrequency/Nfft)/M/M; % Adjusted peakIndex by -1 for correct indexing

    % Time vector for the entire signal
    t = (0:length(rxSig)-1)'/samplingFrequency;

    % Compensate for the frequency offset for the entire signal
    rxSignal_FrequencyCompensated = rxSig.*exp(-1i*2*pi*frequencyOffsetEstimate*t);
end