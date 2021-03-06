function [] = alignMP3(fileNameTarget )
% [] = alignFolder( dirFolder )
% Compute FBR response and save it as a .mat file (if not exist)
% Compute Similarty Matrix and save it as a .mat file (if not exist).
% Compute DTW path and save it as a .mat file (if not exist).
% Compute DTW path from Target onset frame to Score time and save it as
% .csv file

fileNameTarget = strcat(fileNameTarget,'.mp3');
sampleRate=20;

calculateTime(1).name='score handling';
tic;
dirScoreAudio='midi.mp3';

% load score FBR
if exist(dirScoreAudio,'file');
    fileNameScoreFBR='scoreFBR.mat';
    if exist(fileNameScoreFBR,'file');
        load(fileNameScoreFBR);
    else
        scoreFBR=prepareAudio(dirScoreAudio,sampleRate);

        save(fileNameScoreFBR,'scoreFBR');
    end
else
    msg='No midi.mp3 file';
    error(msg);
end
        hold off
        imagesc(scoreFBR);

% read midi.mid
dirMidi = '(midi).mid';
if exist(dirMidi,'file');
    fileNameMidiMat='midiMat.mat';
    dirMidiMat= fileNameMidiMat;
    if exist(dirMidiMat,'file');
        load(dirMidiMat);
    else
        midiMat=readmidi_java(dirMidi);
        save(dirMidiMat,'midiMat');
        beatIndex=midiMat(:,1)';
        dirCSVBeatIndex='beatIndex.csv';
        csvwrite(dirCSVBeatIndex,beatIndex);
        
    end
else
    msg='No (midi).mid file';
    error(msg);
end
calculateTime(1).time=toc;

N=2;

    tic;
    tempName=strsplit(fileNameTarget,'.mp3');
    tempName=tempName{1};
    calculateTime(N).name=tempName;
    % compute target FilterBankResponse
    fileNameTargetFBR=strcat(tempName,'-FBR.mat');
    if exist(fileNameTargetFBR,'file');
        load(fileNameTargetFBR);
    else
        targetFBR=prepareAudio(fileNameTarget,sampleRate);
        save(fileNameTargetFBR,'targetFBR');
    end
    
    figure();
    imagesc(targetFBR);
    
    % compute cosine Similarirty
    fileNameDTWPath=strcat(tempName,'-DTW.mat');
    if exist(fileNameDTWPath,'file');
        load(fileNameDTWPath);
    else
        cosineSimilarity=simmx(scoreFBR+1e-8,targetFBR+1e-8);
        figure();
        imagesc(cosineSimilarity)
        [p,q,~,cost] = dpfast(1-cosineSimilarity);
        hold on
        plot(q,p,'r');
        save(fileNameDTWPath,'p','q','cost');
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
    csvwrite(fileNameCSV,alignOnset);
    calculateTime(N).time=toc;
    N=N+1;

calculateTime(2).time    
dirTime=strcat(tempName,'-time.mat');
save(dirTime, 'calculateTime');
end        
        