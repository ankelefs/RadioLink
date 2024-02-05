function doFFT (sig, M, Fs)
    Nfft = 2^nextpow2(length(sig));
    fftSig = fft(sig.^M, Nfft); % Compute the FFT with the optimized length
    f = Fs/2*linspace(-1, 1, Nfft);
    fftMag = abs(fftshift(fftSig)); % Shift zero frequency components to the center of the spectrum

    % Plot
    figure;
    plot(f, fftMag);
    title('Magnitude Spectrum of Signal');
    xlabel('Frequency (Hz)');
    ylabel('|FFT(Signal)|');
    grid on;

end

