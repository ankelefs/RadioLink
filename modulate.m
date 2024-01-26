%Modulator sim

%Modulate signal M-PSK 
M = 4;
%Assume data is known (random for fun)
data = randi([0 M-1],1000,1);
txSig = pskmod(data,M, pi/M, 'gray'); %input, modulation order, phase offset, symbol order
scatterplot(txSig);

rxSig = awgn(txSig,15);
scatterplot(rxSig);

rxData = pskdemod(rxSig, M,pi/M,'gray');
numErrs = symerr(data,rxData);


