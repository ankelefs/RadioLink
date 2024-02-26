%*************************************************************************
% filename: totalSimulation.m
%
% contents: This file follows the hands-on course and tries to create a
% total simulated simulation protocol using BPSK that can then be implemented 
% on the Adalm-Pluto SDR.
%*************************************************************************


% PARAMETERS
%*************************************************************************
basebandSampleRate = 1e6;           % Baseband sample rate [Hz].
audioSampleRate = 44000;            % Audio sample rate [Hz].
centerFrequency = 1.8e9;            % Center frequency [Hz].

samplesPerFrame = 1024;             % Number of samples per frame [samples/frame].

adalmPlutoChipset = 'AD9364';       % The chosen chipset with LO tuning BW 70-6000 MHz and 56 MHz BW.


% Transmitter exclusive parameters
duration = 5;           % Duration of signal [s].
amplitude = 0.75;  
frequency = 100e3;      % Frequency of the baseband wave [Hz].




% MAIN
%*************************************************************************
% Define a test binary signal sequence and convert to bipolar format
binarySignalArray = [1, 0, 0, 1, 1, 1, 0, 1, 0, 1];
disp(binarySignalArray);
bipolarSignalArray = binaryToBipolarFormat(binarySignalArray);
disp(bipolarSignalArray);


% Setup of Adalm-Pluto SDR
% connectionResult = configurePlutoRadio(adalmPlutoChipset);
% if connectionResult == 1
%     disp("Succesful connection to Adalm-Pluto SDR.");
% else
%     disp("Adalm-Pluto connection failed.")
% end
% 
% 
% rx = sdrrx('Pluto');
% 
% rx.CenterFrequency = centerFrequency;
% rx.BasebandSampleRate = basebandSampleRate;
% rx.SamplesPerFrame = samplesPerFrame;
% rx.OutputDataType = 'double';


% Spectrum analysis
% spectrumAnalysis(rx);
% release(spectrumAnalyzerObj);       % Release the spectrum objects.
% release(rx);                        % Release the system objects.





% FUNCTIONS 
%*************************************************************************
% Changes the input array of 1s and 0s to 1s and -1s.
function [y] = binaryToBipolarFormat(x)
    y = 2.*x - 1;
end


% Continous spectrum analysis
function spectrumAnalysis(rx)

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
