%*************************************************************************
% filename: totalSimulation.m
%
% contents: This file follows the hands-on course and tries to create a
% total simulated simulation protocol that can then be implemented on the
% Adalm-Pluto SDR.
%*************************************************************************

% Fetches the needed parameters and functions
run('environmentParameters.m');
%run('environmentFunctions.m');


sampleRate = 440;


% Creating a sine wave
sineWave = dsp.SineWave(signalAmplitude,signalFrequency,"SampleRate";sampleRate);

% NOT WORKING