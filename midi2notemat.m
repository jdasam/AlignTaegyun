function notemat=midi2notemat(midifile,fs)
% notemat=midi2notemat(midifile,fs)
% convert midifiles into note notation with target frequency(fs)
%

%% Read midi

nmat = midi2nmat(midifile);
nmat(:,8)=nmat(:,6)+nmat(:,7);
t_end = max(nmat(:,8));
len_nmat=length(nmat);
%% make empty bins 
N_length=ceil(t_end*fs);
notemat=zeros(88,N_length);
fprintf('Converting :   0%%');

for i = 1:len_nmat
    percent=round(i/len_nmat*100);
    fprintf('\b\b\b\b\b');fprintf('%4i%%', percent);
    note_index=nmat(i,4)-20; %index conversion. Midi N: 21 -> index 1
    note_start_bin=round(nmat(i,6)*fs);
    note_end_bin=round(nmat(i,8)*fs);
    notemat(note_index,note_start_bin:note_end_bin)=1;
    
end
    
fprintf('\n');

