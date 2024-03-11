%*************************************************************************
% Filename: channel.m
%
% Contents: This file contains the simulated channel block.
%*************************************************************************


function channelSignal = channel(txSignal, samplingFrequency, carrierFrequency, plotOption)

    % Parameters
    snrForSimulation = 10;




    % AWGN added based relative to measurements of signal
    channelSignal_awgn = awgn(txSignal, snrForSimulation, "measured");   
    channelSignal_awgnSum = real(channelSignal_awgn) + imag(channelSignal_awgn);

    % Simulate a phase shift
    phi = 50;                                                                                           % Phase shift of x degrees
    channelSignal_phaseShift = txSignal*exp(1i*deg2rad(phi));                                           % Apply phase shift

    % Simulate a frequency offset:
    % Difference between the LO at the Tx and the Rx 
    frequencyOffset = 15000;                                                                                        % Frequency offset in Hz
    % frequencyOffset = randi([2000 20000]);                                                                          % Random frequency offset in Hz
    t = (0:length(channelSignal_awgn)-1)'/samplingFrequency;                                                        % Time vector in seconds
    channelSignal_frequencyOffset = txSignal.*exp(1i*2*pi*frequencyOffset*t);                                       % Apply frequency offset
    
    channelSignal_allDistortions = channelSignal_awgn*exp(1i*deg2rad(phi));
    channelSignal_allDistortions = channelSignal_allDistortions.*exp(1i*2*pi*frequencyOffset*t);
    
    
    channelSignal = channelSignal_allDistortions;




    if(plotOption)
        
        figure(2);
        channelPlots = tiledlayout(5,1);
        title(channelPlots, "Channel Block");

        % Plot data with AWGN
        awgnPlot = nexttile;
        plot(awgnPlot, real(channelSignal_awgn));
        hold on;
        plot(awgnPlot, imag(channelSignal_awgn));
        hold off;
        title(awgnPlot, "AWGN Applied to Tx Signal");

        % Plot sum of real and imaginary components with AWGN
        awgnRealPlot = nexttile;
        plot(awgnRealPlot, real(channelSignal_awgn));
        title(awgnRealPlot, "AWGN Applied to Tx Signal (real component, baseband)");

        % Plot sum of real and imaginary components with phase shift
        phaseShiftRealPlot = nexttile;
        plot(phaseShiftRealPlot, real(channelSignal_phaseShift));
        title(phaseShiftRealPlot, "Phase Shift of " + {phi} + "° Applied to Tx Signal (real component, baseband)");

        % Plot sum of real and imaginary components with frequency offset
        frequencyOffsetRealPlot = nexttile;
        plot(frequencyOffsetRealPlot, real(channelSignal_frequencyOffset));
        title(frequencyOffsetRealPlot, "Frequency Offset of " + {frequencyOffset} + " Applied to Tx Signal (real component, baseband)");

        % Plot sum of real and imaginary components with all distortions
        allDistortionsRealPlot = nexttile;
        plot(allDistortionsRealPlot, real(channelSignal_allDistortions));
        title(allDistortionsRealPlot, "All Above Distortions Applied to Tx Signal (real component, baseband)");


        % Plot constellation
        % scatterplot(txSignal_modulated);

    end

end