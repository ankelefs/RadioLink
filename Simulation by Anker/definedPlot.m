%*************************************************************************
% Filename: definedPlot.m
%
% Contents: This file contains a user-defined plotting function for
% ease-of-use regarding complex and non-complex function plots of various
% types.
%*************************************************************************


function definedPlot(signal, type, titleString)
    
    global signalIsComplex;
    

    if ~isreal(signal)    
        signalIsComplex = 1;
    end


    if type == 1 % Plot
        
        if signalIsComplex
            plot(real(signal));
            hold on;
            plot(imag(signal));
            hold off;
        else 
            plot(signal);
        end
    
    elseif type == 2 % Stem
        
        if signalIsComplex
            stem(real(signal));
            hold on;
            stem(imag(signal));
            hold off;
        else 
            stem(signal);
        end

    elseif type == 3 % Scatter
        
        scatterplot(signal);
    
    else
        
        disp("No plot type specified.");
    
    end

    title(titleString);

end