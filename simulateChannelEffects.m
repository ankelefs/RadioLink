function [y] = simulateChannelEffects(x, fs, snr, freqOffset, phaseOffset, distortionFactor)
    % Applies various channel effects to an input signal
    %
    % Inputs:
    %   x - The input signal
    %   fs - Sampling frequency
    %   snr - Signal-to-noise ratio for AWGN
    %   freqOffset - Frequency offset in Hz
    %   phaseOffset - Phase offset in radians
    %   distortionFactor - Factor controlling non-linear distortion (0 for no distortion)
    %
    % Output:
    %   y - The output signal after applying channel effects
    
    % Apply frequency offset
    t = (0:length(x)-1)'/fs; % Time vector
    x = x .* exp(1j*2*pi*freqOffset*t);
    
    % Apply phase offset
    x = x * exp(1j*phaseOffset);
    
    % Apply AWGN
    y = awgn(x, snr, 'measured');
    
    % Apply non-linear distortion if distortionFactor is not zero
    if distortionFactor ~= 0
        y = y + distortionFactor * abs(y).^2 .* y;
    end
end