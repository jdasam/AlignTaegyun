function [midiTemplate] = prepareMidi(dirMidi, demandSampleRate)
% [midiTemplate] = prepareAudio(dirAudio) 
% Load midifile and return Matrix-form of note information.
% 
% dirMidi : string that indicate absolute directory of target Midifile
% demandSampleRate : double. nSample per second (demanding). 
% Default is 50 (1 sample : 20ms)
% need to be rewriten

%	Version 1.00
%	06.07.2016
%	Copyright (c) by Taegyun Kwon
%	ilcobo2@kaist.ac.kr

if nargin<2; demandSampleRate = 50; end;

nmat = midi2nmat(dirMidi);
nmat(:,8)=nmat(:,6)+nmat(:,7);
t_end = max(nmat(:,8));
len_nmat=length(nmat);
%% make empty bins 
N_length=ceil(t_end*demandSampleRate);
notemat=zeros(88,N_length);
fprintf('Converting :   0%%');

for i = 1:len_nmat
    percent=round(i/len_nmat*100);
    fprintf('\b\b\b\b\b');fprintf('%4i%%', percent);
    note_index=nmat(i,4)-20; %index conversion. Midi N: 21 -> index 1
    note_start_bin=round(nmat(i,6)*demandSampleRate);
    note_end_bin=round(nmat(i,8)*demandSampleRate);
    notemat(note_index,note_start_bin:note_end_bin)=1;
end
echoTime=0.1; % 0.1sec
echoNSample=round(echoTime*demandSampleRate);
midiTemplate=midi_mat_manipul(notemat,echoNSample);
fprintf('\n');
end

