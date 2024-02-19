function idx = preDetector(rxSig, pre, M, sps)
     preModulated = pskmod(pre, M, pi/M, 'gray');
     rxSigDown = downconvert(rxSig,sps);
    [crossCorr, lags] = xcorr(rxSigDown, preModulated);
    %Find the k (lags) largest elements in the crosscorr function
    [,maxIdx] = maxk(crossCorr, lags);
    for i = 1:length(lags)
        if(crossCorr(i) < 0)
           
        else
            break
        end
           
    end
    
end