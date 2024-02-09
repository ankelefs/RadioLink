%*************************************************************************
% filename: totalSimulation.m
%
% contents: This file follows the hands-on course and tries to create a
% total simulated simulation protocol using BPSK that can then be implemented 
% on the Adalm-Pluto SDR.
%*************************************************************************


% PARAMETERS
%*************************************************************************
% Signal
sineWaveFrequency = 440;                            % [Hz].
samplingRate = 44100;                               % [Hz].
signalLength = 1000;                                % Number of samples per frame [samples/frame].
samplingPeriod = 1/samplingRate;                    % [s].
signalTime = (0:signalLength - 1)*samplingPeriod;

% Channel
AWGNScaleFactor = 0.2;            % Scale factor for the randn-generator.

% Raised Cosine Tx Filter
numberOfSymbolDurations = 4;                    % Filter span in symbol durations.
rollOffFactor = 0.5;                            % Roll-off factor.
samplesPerSymbol = 2;                           % Upsampling factor [samples/symbol].
symbolDurationInSeconds = 1/samplesPerSymbol;   % [s]





% MAIN
%*************************************************************************
% Define a test binary signal sequence and convert to bipolar format
binarySignalArray = [1, 0, 0, 1, 1, 1, 0, 1, 0, 1];
disp(binarySignalArray);
bipolarSignalArray = binaryToBipolarFormat(binarySignalArray);
disp(bipolarSignalArray);
signalArrayTimeVector = 0:length(binarySignalArray)-1;


% plotDiscreteSignal(bipolarSignalArray, signalArrayTimeVector);
% plotDiscreteSignal(binarySignalArray, signalArrayTimeVector);

% Create a sinewave
sine = dsp.SineWave(...
    'Amplitude', 1, ...
    'Frequency', sineWaveFrequency, ...
    'SampleRate', samplingRate, ...
    'SamplesPerFrame', signalLength);

sineWave = sine();




%plotSignalAndFFT(sineWave, samplingRate, signalTime);

sineWaveNoisy = channelSimulation(sineWave, AWGNScaleFactor);

%plotSignalAndFFT(sineWaveNoisy, samplingRate, signalTime);


% Defining and plotting different transmission filters g(t)
% raisedCosineTxFilter(numberOfSymbolDurations, 0.5, samplesPerSymbol, 1, 1);
% raisedCosineTxFilter(numberOfSymbolDurations, 0.9, samplesPerSymbol, 1, 1);
% raisedCosineTxFilter(numberOfSymbolDurations, 1, samplesPerSymbol, 1, 1);
raisedCosineTxFilter(numberOfSymbolDurations, rollOffFactor, samplesPerSymbol, 1, 0);


raisedCosineFilter = raisedCosineTxFilter(numberOfSymbolDurations, rollOffFactor, samplesPerSymbol, 0, 0);

test = raisedCosineFilter(binarySignalArray);

plot(test);






% FUNCTIONS 
%*************************************************************************
% Changes the input array of 1s and 0s to 1s and -1s.
function output = binaryToBipolarFormat(input)
    output = 2 .* input - 1;
end
    

% Plot the signal and its corresponding FFT
function plotSignalAndFFT(signal, samplingRate, timeVector)
    figure();
    plot(timeVector, signal, "LineWidth", 2);
    title("Signal");
    xlabel("Time (s)");
    ylabel("Amplitude");
    grid on;

    figure();
    plot(samplingRate/length(signal)*(-length(signal)/2:length(signal)/2-1), abs(fftshift(fft(signal))), "LineWidth", 2);
    title("FFT Spectrum in the Positive and Negative Frequencies");
    xlabel("Frequency (Hz)");
    ylabel("|Amplitude|");
    grid on;
end


% Plots a discrete signal in time-domain
function plotDiscreteSignal(signal, timeVector)
    figure();
    stem(timeVector, signal, "LineWidth", 2);
    title("Signal");
    xlabel("Time (s)");
    ylabel("Amplitude");
    grid on;
end


% Simulation of a AWGN channel
% The input signal is affected by AWGN, without any implemented filter
% (yet)
function output = channelSimulation(input, AWGNScaleFactor)
    output = input + AWGNScaleFactor.*randn(length(input), 1);
end


% Creates a Raised Cosine Transmit Filter with Gain = 1
function outputFilter = raisedCosineTxFilter(numberOfSymbolDurations, rollOffFactor, samplesPerSymbol, plotFilter, holdOn)
    rctFilt = comm.RaisedCosineTransmitFilter(...
        Shape = 'Normal', ...
        RolloffFactor = rollOffFactor, ...
        FilterSpanInSymbols = numberOfSymbolDurations, ...
        OutputSamplesPerSymbol = samplesPerSymbol);
    
    outputFilter = rctFilt;

    if plotFilter
        if not(holdOn)
            figure();
        end
        impz(rctFilt.coeffs.Numerator); % Visualize the impulse response
        xlabel("Samples (n)");
        grid on;

        if holdOn
            hold on;
        end
    end
end


