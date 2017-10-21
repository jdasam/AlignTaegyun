function dlnco = make_decay(lnco, samplingRate) 
    
    dlnco = lnco;
    for i = 1 : 0.2 * samplingRate - 1
        dlnco = max(dlnco, [zeros(12,i), lnco(:,1:size(lnco,2)-i)] * sqrt(  (0.2 * samplingRate - i) / (0.2 * samplingRate) ));
    end



end