function [] = alignFolder_VerChroma2( dirFolder )
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

if nargin < 1
    dirFolder = pwd;
end
cd(dirFolder)


sampleRate=100;
useChroma = false;


dataSet = getFileListWithExtension('*.mid');

for dataIndex = 1 : length(dataSet)
    fileName = dataSet{dataIndex};
    if length(strsplit(fileName, '.')) > 1
        continue
    end

    audioName = strcat(fileName, '.wav');
    audioGTname = strcat({'- '}, fileName, '.mid_note_st.wav');
    audioGTname = audioGTname{1};

    midiName = strcat(fileName, '.mid');
    midiGTname = strcat(fileName, '.mid_note_st.mid');

    errorFileName = strcat(fileName, '_error.mat');
    if exist(errorFileName,'file');
        continue
    end
    
    %[scoreFBR, scoreDLNCO] =prepareAudio(audioName,sampleRate, useChroma);
    midiMat=readmidi_java(midiName, true);
    midiMat(:,7) = midiMat(:,7) + midiMat(:,6);
    
    basicParameter = basicParameterInitialize();
    basicParameter.nfft = 441;
    basicParameter.window = 1050;
    basicParameter.onsetFine = 3;
    basicParameter.offsetFine = 3;
    midiLength = int32(( midiMat(size(midiMat,1), 7) + 1) * 100);
    scoreMIDI = midi2MatrixOption(midiMat, midiLength, basicParameter);
    scoreMIDI = scoreMIDI(2:89,:);
    scoreFBR = [zeros(20,size(scoreMIDI,2)); scoreMIDI; zeros(12,size(scoreMIDI,2))];
    
    
    paramCLP.applyLogCompr = 1;
    paramCLP.factorLogCompr = 50000;
    paramCLP.applyNormalization =0 ;
    
    [~,~,scoreDLNCO] = onsetDetection(scoreFBR+eps, sampleRate, paramCLP);
    
    if useChroma
        scoreFBR = pitch_to_chroma(scoreFBR,paramCLP);
    else
        scoreFBR = scoreFBR(21:108,:);
    end
    
    scoreDLNCO(find(isnan(scoreDLNCO))) = 0;
%     if size(scoreFBR, 2) > 30000
%         continue
%     end
    
    


    [targetFBR, targetDLNCO] =prepareAudio(audioGTname,sampleRate, useChroma);
    
    % compute cosine Similarirty

    cosineSimilarity=simmx(scoreFBR+eps,targetFBR+eps);
%     clear scoreFBR targetFBR
    euclideanDistance = pdist2(scoreDLNCO', targetDLNCO', 'euclidean');
%     clear scoreDLNCO targetDLNCO
    combinedDistance = 1-cosineSimilarity + euclideanDistance;
%     clear cosineSimilarity euclideanDistance
    [p,q,~,cost] = dpfast(combinedDistance);
%         save(dirDTWPath,'p','q','cost');
    
    alignOnset=zeros(1,size(midiMat,1));
    onsetFrame=ceil(midiMat(:,6)*sampleRate);
    for nOnset=1:length(alignOnset);
        if ~isempty(find(p>=onsetFrame(nOnset),1,'first'));
            alignOnset(nOnset)=q(find(p>=onsetFrame(nOnset),1,'first'));
        else
            alignOnset(nOnset)=q(end);
        end
    end
    
    midiMatGT = readmidi_java(midiGTname);
    
    
%     alignOnset=alignOnset/sampleRate;
    errorVector = abs(ceil(midiMatGT(:,6)'*sampleRate)  - alignOnset);
    mean(errorVector) * (1000/sampleRate)
    save(errorFileName, 'errorVector');
 
    
end

end        
        
        
        