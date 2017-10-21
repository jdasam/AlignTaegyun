function [onset_pitch, lnco, dlnco] = onsetDetection(f_pitch, samplingRate, parameter)

    f_pitch_shift =  [zeros(size(f_pitch,1),1) f_pitch(:,1:size(f_pitch,2)-1)];
    
    
    onset_pitch = f_pitch - f_pitch_shift;
    onset_pitch(onset_pitch<0) = 0;
    
    %parameter.factorLogCompr = 100;
    

    [chroma_onset_pitch, sideinfo] = pitch_to_chroma(onset_pitch, parameter);

    sum_CO = sqrt(sum(chroma_onset_pitch.^2 ,1));
    
    
    norm_max = zeros(1,size(sum_CO,2));
    
    for i = 1:length(norm_max)
        if i <= samplingRate
            norm_max(i) = max(sum_CO(1:i+samplingRate));
        elseif i+samplingRate > size(sum_CO,2)
            norm_max(i) = max(sum_CO(i-samplingRate:end));
        else
            norm_max(i) = max(sum_CO(i-samplingRate:i+samplingRate));
        end               
    end
    
    lnco = bsxfun(@rdivide, chroma_onset_pitch, norm_max);
    
    dlnco = make_decay(lnco, samplingRate);
    
    
end