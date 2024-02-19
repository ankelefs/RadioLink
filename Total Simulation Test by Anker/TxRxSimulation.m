%*************************************************************************
% Filename: TxRxSimulation.m
%
% Contents: This file contains the full simulation of Tx and Rx. It is
% divided into (function) blocks for ease of use.
%*************************************************************************


%%%%%%%%%%%%%%%%%%%%%%
%     PARAMETERS     %
%%%%%%%%%%%%%%%%%%%%%%
bitsPerSymbol = 2;
numberOfSymbols = 2^bitsPerSymbol;
upsampleFactor = 3;

% Root Raised Cosine Tx Filter
rollOffFactor = 0.5;  
filterSpan = 15;                          
samplesPerSymbol = 4;  


%%%%%%%%%%%%%%%%%%
%     SIGNAL     %
%%%%%%%%%%%%%%%%%%
microphoneDataPacket = [0 1 0 0 1 0 1 1]';  % Array must be a column vector.



% QPSK symbol mapping with Grey-coding (hard-defined)
TxSignal_QPSK = pskmod(microphoneDataPacket,MSymbols,pi/MSymbols,"gray","InputType","bit","OutputDataType","double");
scatterplot(TxSignal_QPSK);
figure()
stem(real(TxSignal_QPSK))
hold on;
stem(imag(TxSignal_QPSK))
hold off;

% Upsample
TxSignal_QPSKUpsampled = upsample(TxSignal_QPSK,10);   % Adds #upsampleFactor zeros in between each complex amplitude.
figure()
stem(real(TxSignal_QPSKUpsampled))
hold on;
stem(imag(TxSignal_QPSKUpsampled))
hold off;

% Root Raised Cosine Tx Filter Object
% Number of taps of the filter equals FilterSpanInSymbols *
% OutputSamplesPerSymbol.
rootRaisedCosineFilter = comm.RaisedCosineTransmitFilter(...
        Shape='Square root',...
        RolloffFactor=0.1,...
        FilterSpanInSymbols=8,...
        OutputSamplesPerSymbol=4,...
        Gain=1);

TxSignal_Filtered = rootRaisedCosineFilter(TxSignal_QPSKUpsampled);

eyediagram(TxSignal_Filtered,2*4);


% EXAMPLE
data = randi([0 3],1000,1);
modSig = pskmod(data,4,pi/4);
sps=4;
figure()
plot(real(modSig))
hold on;
plot(imag(modSig))
hold off;
txfilter = comm.RaisedCosineTransmitFilter('OutputSamplesPerSymbol',sps);
txSig = txfilter(modSig);
figure()
plot(real(txSig))
hold on;
plot(imag(txSig))
hold off;
eyediagram(txSig,2*sps)


% FOR LATER: use isreal() to determine complex number —> for implementing a
% print/plot function depending on input.


figure()
stem(real(TxSignal_Filtered))
hold on;
stem(imag(TxSignal_Filtered))
hold off;

figure()
plot(real(TxSignal_Filtered))
hold on;
plot(imag(TxSignal_Filtered))
hold off;


% Upconversion
% I THINK THIS IS DONE ON THE PLUTO NATIVELY
% Supports complex numbers natively.
upconvertion = dsp.DigitalUpConverter('InterpolationFactor',20,...
    'SampleRate',1e6,...
    'Bandwidth',2e3,...
    'StopbandAttenuation',55,...
    'PassbandRipple',0.2,...
    'CenterFrequency',50e3);

TxSignal_FilteretAndUpconverted = upconvertion(TxSignal_Filtered);



% figure()
% stem(TxSignal_FilteretAndUpconverted)
figure()
plot(TxSignal_FilteretAndUpconverted)









% Channel simulation with AWGN
RxSignal_raw = awgn(TxSignal_FilteretAndUpconverted,0.1,"measured");

% figure()
% stem(RxSignal_raw)
figure()
plot(RxSignal_raw)




% Calculates the number of symbol errors
%numErrs = symbolErrors(dataIn,dataOut);






