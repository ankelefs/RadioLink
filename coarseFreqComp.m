function [rxSigCompensated, frequencyOffsetEstimate] = coarseFreqComp(rxSig, Fs,M, Nsamples)
   
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
    frequencyOffsetEstimate = ((peakIndex-1) * Fs / Nfft)/M/M; % Adjusted peakIndex by -1 for correct indexing

    % Time vector for the entire signal
    t = (0:length(rxSig)-1)'/Fs;

    % Compensate for the frequency offset for the entire signal
    rxSigCompensated = rxSig .* exp(-1i * 2 * pi * frequencyOffsetEstimate * t);
end
