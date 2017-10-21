function [] = alignFolder_VerChromaSaveMIDI( dirFolder )
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
useChroma = true;
useMIDI = true;

dataSet = getFileListWithExtension('*.mp3');

% fileID = fopen('test_list.txt','r');
% text = textscan(fileID, '%s');
% text = text{1,1};
% 
% for i = 1:length(text)
%     temp = strsplit(text{i}, '_input.npy');
%     testList{i} = temp{1};
% end


for dataIndex = 1 : length(dataSet)
    fileName = dataSet{dataIndex};
    if strcmp(fileName, 'midi')
        continue
    end
%     if ~ismember(fileName,testList)
%         continue
%     end
           
%     if length(strsplit(fileName, '.')) > 1
%         continue
%     end

    audioName = 'midi.mp3';
    audioGTname = strcat(fileName, '.mp3');
    
    %audioGTname = audioGTname{1};

    midiName = '(midi).mid';
    %midiGTname = strcat(fileName, '.mid_note_st.mid');

    midiMat=readmidi_java(midiName, true);
    midiMat(:,7) = midiMat(:,7) + midiMat(:,6);
    
    if useMIDI

        basicParameter = basicParameterInitialize();
        basicParameter.nfft = 441;
        basicParameter.window = 1050;
        basicParameter.onsetFine = 3;
        midiLength = int32(( midiMat(size(midiMat,1), 7) + 1) * 100);
        scoreMIDI = midi2MatrixOption(midiMat, midiLength, basicParameter);
        scoreMIDI = scoreMIDI(2:89,:);
        scoreFBR = [zeros(20,size(scoreMIDI,2)); scoreMIDI; zeros(12,size(scoreMIDI,2))];


        paramCLP.applyLogCompr = 1;
        paramCLP.factorLogCompr = 50000;
        paramCLP.applyNormalization =0 ;

        [~,~,a_onset] = onsetDetection(scoreFBR+eps, sampleRate, paramCLP);

        if useChroma
            a = pitch_to_chroma(scoreFBR,paramCLP);
        else
            a = scoreFBR(21:108,:);
        end        
        a_onset(find(isnan(a_onset))) = 0;
    else
        [a, a_onset] =prepareAudio(audioName,sampleRate, useChroma);
    end
    


    [b, b_onset] =prepareAudio(audioGTname,sampleRate, useChroma);
    
%     save('data_semigram_dlnco_midi.mat', 'a', 'a_onset', 'b','b_onset');
    
    
%     system('python /Users/Da/Documents/mat_fastdtw_DLNCO.py data_semigram_dlnco_midi.mat semigram');
    % compute cosine Similarirty

    cosineSimilarity=simmx(a+eps,b+eps);
%     clear scoreFBR targetFBR
    euclideanDistance = pdist2(a_onset', b_onset', 'euclidean');
%     clear scoreDLNCO targetDLNCO
    combinedDistance = 1-cosineSimilarity + euclideanDistance * 1.2;
%     clear cosineSimilarity euclideanDistance
    [p,q,~,cost] = dpfast(combinedDistance);
%     [p,q,~,cost] = dpfast(euclideanDistance);

%         save(dirDTWPath,'p','q','cost');

%     load('data_semigram_dlnco_midi_path');
%     p = path(:,1);
%     q = path(:,2);

    imagesc(combinedDistance)
    hold on
    plot(q, p, 'LineWidth', 3, 'Color', 'r')
    hold off


    alignOnset=zeros(1,size(midiMat,1));
    alignOffset=zeros(1,size(midiMat,1));
    onsetFrame=ceil(midiMat(:,6)*sampleRate);
    offsetFrame=ceil(midiMat(:,7)*sampleRate);
    for nOnset=1:length(alignOnset);
        if ~isempty(find(p>=onsetFrame(nOnset),1,'first'));
            alignOnset(nOnset)=q(find(p>=onsetFrame(nOnset),1,'first'));
            alignOffset(nOnset)=q(find(p>=offsetFrame(nOnset),1,'first'));
        else
            alignOnset(nOnset)=q(end);
            alignOffset(nOnset)=q(end);
        end
    end
    
    %midiMatGT = readmidi_java(midiGTname);
    
    midiMat(:,6) = alignOnset/sampleRate;
    midiMat(:,7) = alignOffset/sampleRate;
    midiMat(:,7) = midiMat(:,7) - midiMat(:,6);
    midiMat(midiMat(:,7)<=0, 7) = 0.1;
    
    saveName = strcat(fileName, '.mid');
    writemidi_seconds(midiMat, saveName);

    
end

end        
        
        
        