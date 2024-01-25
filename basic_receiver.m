% Real-time Spectrum Analysis using ADALM-PLUTO

% Setup parameters
% run('params.m');


% Setup PlutoSDR System object for receiving
rx = sdrrx('Pluto');
rx.CenterFrequency = fc;
rx.BasebandSampleRate = fs;
rx.SamplesPerFrame = numSamples;
rx.OutputDataType = 'double';

% Spectrum analyze
spectrumAnalyze(rx);
release(spectrumAnalyzerObj);
% Release the System objects
release(rx);

