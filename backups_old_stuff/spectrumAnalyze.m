% performSpectrumAnalysis.m
function spectrumAnalyze(rx)

    % Create a Spectrum Analyzer System object
    spectrumAnalyzerObj = dsp.SpectrumAnalyzer(...
    'SampleRate', rx.BasebandSampleRate, ...
    'SpectralAverages', 10, ...
    'YLimits', [-100, 30], ...
    'Title', 'Real-Time Spectrum of Received Signal', ...
    'FrequencySpan', 'Full'); 

    disp('Starting real-time spectrum analysis. Close the Spectrum Analyzer window to stop.');
    keepRunning = true;
    while keepRunning
        try
            % Receive signal from Pluto SDR
            rxSig = rx();

            % Plot spectrum
            spectrumAnalyzerObj(rxSig);
        catch
            % If an error occurs (likely because the window was closed), exit the loop
            keepRunning = false;
        end
    end
    release(spectrumAnalyzerObj);
    disp('Real-time spectrum analysis stopped.');
end
