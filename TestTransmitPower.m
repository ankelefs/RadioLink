tx = sdrtx('Pluto',...
    'CenterFrequency',1.7975e9, ...
    'BasebandSampleRate',800e3, ...
    'ChannelMapping',1);


mod = comm.DPSKModulator('BitInput',true);

for counter = 1:20
   data = randi([0 1],30,1);
   modSignal = mod(data);
end
data = 1;
transmitRepeat(tx, modSignal)

%Bruk transmitRepeat(tx, data) etter at du har satt opp tx-objektet med sdrtx