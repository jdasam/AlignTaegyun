function [] = alignFolder_Ver7( dirFolder )
% [] = alignFolder( dirFolder )
% Compute FBR response and save it as a .mat file (if not exist)
% Compute Similarty Matrix and save it as a .mat file (if not exist).
% Compute DTW path and save it as a .mat file (if not exist).
% Compute DTW path from Target onset frame to Score time and save it as
% .csv file

% Ver2 : add time checking, and make exception for 'midi.mp3' not to be
% aligned
% Ver3 : save similarity Matrix
% Ver4 : changed sampleRate as 200, change mid2nmat function to
% readmidi_java
% Ver5 : not save Simmx
% Ver6 : save tempo base onsets into beatIndex.csv
sampleRate=20;

calculateTime(1).name='score handling';
tic;
dirScoreAudio=fullfile(dirFolder,'midi.mp3');

% load score FBR
if exist(dirScoreAudio,'file');
    fileNameScoreFBR='scoreFBR.mat';
    dirScoreFBR=fullfile(dirFolder,fileNameScoreFBR);
    if exist(dirScoreFBR,'file');
        load(dirScoreFBR);
    else
        scoreFBR=prepareAudio(dirScoreAudio,sampleRate);
        save(dirScoreFBR,'scoreFBR');
    end
else
    msg='No midi.mp3 file';
    error(msg);
end

% read midi.mid
dirMidi=fullfile(dirFolder,'(midi).mid');
if exist(dirMidi,'file');
    fileNameMidiMat='midiMat.mat';
    dirMidiMat=fullfile(dirFolder,fileNameMidiMat);
    if exist(dirMidiMat,'file');
        load(dirMidiMat);
    else
        midiMat=readmidi_java(dirMidi);
        save(dirMidiMat,'midiMat');
        beatIndex=midiMat(:,1)';
        dirCSVBeatIndex=fullfile(dirFolder,'beatIndex.csv');
        csvwrite(dirCSVBeatIndex,beatIndex);
        
    end
else
    msg='No (midi).mid file';
    error(msg);
end
calculateTime(1).time=toc;
targets=dir(fullfile(dirFolder,'*.mp3'));
fileNameTargets={targets.name}';
N=2;
for nTarget=1:numel(fileNameTargets);
    tic;
    fileNameTarget=fileNameTargets{nTarget};
    if strcmp(fileNameTarget,'midi.mp3'); break; end;
    tempName=strsplit(fileNameTarget,'.mp3');
    tempName=tempName{1};
    calculateTime(N).name=tempName;
    % compute target FilterBankResponse
    fileNameTargetFBR=strcat(tempName,'-FBR.mat');
    dirTargetFBR=fullfile(dirFolder,fileNameTargetFBR);
    if exist(dirTargetFBR,'file');
        load(dirTargetFBR);
    else
        dirTargetAudio=fullfile(dirFolder,fileNameTarget);
        targetFBR=prepareAudio(dirTargetAudio,sampleRate);
        save(dirTargetFBR,'targetFBR');
    end
    
    % compute cosine Similarirty
    fileNameDTWPath=strcat(tempName,'-DTW.mat');
    dirDTWPath=fullfile(dirFolder,fileNameDTWPath);
    if exist(dirDTWPath,'file');
        load(dirDTWPath);
    else
        cosineSimilarity=simmx(scoreFBR+1e-8,targetFBR+1e-8);
        [p,q,~,cost] = dpfast(1-cosineSimilarity);
        save(dirDTWPath,'p','q','cost');
    end;
    
    alignOnset=zeros(1,size(midiMat,1));
    onsetFrame=round(midiMat(:,6)*sampleRate);
    for nOnset=1:length(alignOnset);
        if ~isempty(find(p>=onsetFrame(nOnset),1,'first'));
            alignOnset(nOnset)=q(find(p>=onsetFrame(nOnset),1,'first'));
        else
            alignOnset(nOnset)=q(end);
        end
    end
    alignOnset=alignOnset/sampleRate;
    fileNameCSV=strcat(tempName,'.csv');
    dirCSV=fullfile(dirFolder,fileNameCSV);
    csvwrite(dirCSV,alignOnset);
    calculateTime(N).time=toc;
    N=N+1;
end
dirTime=fullfile(dirFolder,'time.mat');
save(dirTime, 'calculateTime');
end        
        
        
        