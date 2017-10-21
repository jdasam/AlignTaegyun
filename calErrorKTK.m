function diff = calErrorKTK(midi_align, midi_ref) 
    diff = [];
    for i=21:108
        original_onsets = midi_ref(midi_ref(:,4)==i, 6);
        aligned_onsets = midi_align(midi_align(:,4)==i, 6);
        if length(original_onsets) && length(aligned_onsets)
            for n = 1:length(original_onsets)
                closest_diff = min(abs(aligned_onsets - original_onsets(n)));
                if closest_diff < 3
                    diff(length(diff)+1) = closest_diff;
                end
            end
        end
    end
     

end
