% Syncronisation Parameters
sequenceLength = 32;  % Length of synchronization sequence
syncSequence = [1 0 1 0 1 0 1 1];  % Example synchronization sequence

% Create repeated synchronization sequence
numRepetitions = 4;
fullSequence = repmat(syncSequence, 1, numRepetitions);

% Display the generated sequence
disp('Generated Synchronization Sequence:');
disp(fullSequence);

%--------------------------------------------------------------------------
% Audio recording 
 


%--------------------------------------------------------------------------
% Compressing audio

%--------------------------------------------------------------------------
% Symbol coding & gray coding of symbols


%--------------------------------------------------------------------------

%Creating packet

packet = [fullSequence, audioData];


%--------------------------------------------------------------------------
%Functions

% Function to wait for a key press

% Function to wait for a key press

