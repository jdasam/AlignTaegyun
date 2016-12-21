function [] = dtw2midi(fileName)

% change midi onset time

midi = readmidi_java('(midi).mid');
dtwMatName = strcat(fileName, '-DTW.mat');
load(dtwMatName);

audioStamp = q;
midiStamp = p;


%split alignmentMatrix

midi_copy = midi;


for i = 1:length(midi)
   midi(i,7) = midi(i,6) + midi(i,7); 
    
   onsetFrameIndex = floor(midi(i,6) * 20) +1;
   alignIndex = min ( find(midiStamp == onsetFrameIndex));
   outputOnset = audioStamp(alignIndex);
   midi_copy(i,6) = (outputOnset-1) / 20;
   
   
   offsetFrameIndex = floor(midi(i,7) * 20) +1;
   alignIndex2 = max( find(midiStamp == offsetFrameIndex));
   outputOffset = audioStamp(alignIndex2);
   midi_copy(i,7) = (outputOffset-1) / 20;

   if midi_copy(i,7) < 0
       midi_copy(i,7) = 0.01;
   end
end


midi_copy(:,7) = midi_copy(:,7) - midi_copy(:,6);

outputName = strcat(fileName, '-aligned.mid');
writemidi_seconds(midi_copy,outputName);

end
