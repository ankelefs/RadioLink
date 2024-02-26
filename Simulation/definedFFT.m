%*************************************************************************
% Filename: definedFFT.m
%
% Contents: This file contains a user-defined FFT plotting-function for
% ease-of-use.
%*************************************************************************


function definedFFT(signal,M,samplingFrequency)
    
    % Compute the FFT with the optimized length
    Nfft = 2^nextpow2(length(signal));
    fftSig = fft(signal.^M, Nfft);      
    f = samplingFrequency/2*linspace(-1, 1, Nfft);
    fftMag = abs(fftshift(fftSig));     % Shift zero frequency components to the center of the spectrum

    % Plot
    figure;
    plot(f,fftMag);
    title('Magnitude Spectrum of Signal');
    xlabel('Frequency (Hz)');
    ylabel('|FFT(Signal)|');
    grid on;

end