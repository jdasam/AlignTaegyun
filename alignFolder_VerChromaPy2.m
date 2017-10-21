function [] = alignFolder_VerChromaPy2( dirFolder, option )
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

if nargin<2
    option = [];
    option.saveMIDI = false;
    option.audioToAudio = false;
    option.calError = false;
    option.audioExtension = 'wav';
    option.audioGTname = 'simonRattle.wav';
    option.midiName = '(midi).mid';
    option.midiAdditionalName = '_sync.mid';
    option.useMIDI = false; 
    option.useChroma = false;
    option.sampleRate = 100;
end


if ~isfield(option, 'saveMIDI') option.saveMIDI = false; end
if ~isfield(option, 'audioToAudio') option.audioToAudio = false; end
if ~isfield(option, 'calError') option.calError = false; end
if ~isfield(option, 'audioExtension') option.audioExtension = 'wav'; end
if ~isfield(option, 'audioGTname') option.audioGTname = 'GT.wav'; end
if ~isfield(option, 'midiAdditionalName') option.midiAdditionalName = '_sync.mid'; end
if ~isfield(option, 'midiGTname') option.midiGTname = '(midi).mid'; end
if ~isfield(option, 'useMIDI') option.useMIDI = false; end
if ~isfield(option, 'useChroma') option.useChroma = false; end
if ~isfield(option, 'sampleRate') option.sampleRate = 100; end
if ~isfield(option, 'saveDropbox') option.saveDropbox = false; end

cd(dirFolder)
dataSet = getFileListWithExtension(strcat('*.',option.audioExtension));

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
    if strcmp(strcat(fileName, '.', option.audioExtension) , option.audioGTname)
        continue
    end
    
    fileName = strsplit(fileName, option.audioExtension);
    fileName = fileName{1};

    if option.audioToAudio 
        csvFileName = strcat(fileName, '.csv');
        if exist(csvFileName, 'file');
            continue
        end
    end
    
    
    if option.calError
        errorFileName = strcat(fileName, '_error.mat');
        if exist(errorFileName,'file');
            continue
        end
    end
    
%     if strcmp(fileName, 'Chopin_op38_p01')
%         continue
%     end
    
%     if ~ismember(fileName,testList)
%         continue
%     end
           
%     if length(strsplit(fileName, '.')) > 1
%         continue
%     end

    audioName = strcat(fileName,'.' , option.audioExtension);
    audioGTname = option.audioGTname;
    midiGTname = option.midiGTname;
%     midiName = strcat(fileName, option.midiAdditionalName);

%     audioGTname = strcat({'- '}, fileName, '.mid_note_st.wav');
%     audioGTname = strsplit(fileName, '_p');
%     audioGTname = strcat(audioGTname{1}, '_p01.wav');
%     audioGTname = audioGTname{1};


%     midiGTname = strcat(fileName, '.mid_note_st.mid');
%     midiGTname = strsplit(fileName, '_p');
%     midiGTname = strcat(fileName, '_p01_sync.mid');


%     errorFileName = strcat('semigram_dlnco_MIDI_error/', fileName, '_error.mat');

    

    [a, a_onset] =prepareAudio(audioName,option.sampleRate, option.useChroma);
    
    
    audioGTmatName = strcat(audioGTname, '.mat');
    if option.useMIDI
        midiMat=readmidi_java(midiGTname, true);
        midiMat(:,7) = midiMat(:,7) + midiMat(:,6);

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

        [~,~,b_onset] = onsetDetection(scoreFBR+eps, option.sampleRate, paramCLP);

        if useChroma
            b = pitch_to_chroma(scoreFBR,paramCLP);
        else
            b = scoreFBR(21:108,:);
        end        
        b_onset(find(isnan(b_onset))) = 0;
    elseif exist(audioGTmatName,'file');
        load(audioGTmatName);
    else
        [b, b_onset] =prepareAudio(audioGTname, option.sampleRate, option.useChroma);
        if option.audioToAudio save(strcat(audioGTname, '.mat'),'b','b_onset'); end
    end

    
    
    save('data_semigram_dlnco_midi.mat', 'a', 'a_onset', 'b','b_onset');
    
    
    system('python /Users/Da/Documents/mat_fastdtw_DLNCO.py data_semigram_dlnco_midi.mat semigram')
    % compute cosine Similarirty

%     cosineSimilarity=simmx(a+eps,b+eps);
%     clear scoreFBR targetFBR
%     euclideanDistance = pdist2(a_onset', b_onset', 'euclidean');
%     clear scoreDLNCO targetDLNCO
%     combinedDistance = 1-cosineSimilarity + euclideanDistance;
%     clear cosineSimilarity euclideanDistance
%     [p,q,~,cost] = dpfast(combinedDistance);
% %         save(dirDTWPath,'p','q','cost');

    load('data_semigram_dlnco_midi_path');
    p = path(:,1);
    q = path(:,2);

    
    
    if ~option.audioToAudio
        midiMat=readmidi_java(midiGTname, true);
        alignOnset=zeros(1,size(midiMat,1));
        onsetFrame=ceil(midiMat(:,6)*option.sampleRate);
        for nOnset=1:length(alignOnset);
            if ~isempty(find(q>=onsetFrame(nOnset),1,'first'));
                alignOnset(nOnset)=p(find(q>=onsetFrame(nOnset),1,'first'));
            else
                alignOnset(nOnset)=p(end);
            end
        end
        alignOnset = alignOnset ./ 100;
        csvwrite(strcat(fileName,'.csv'), alignOnset);
    else % audioToAudio case. calculate audio path
        for index = 1:size(b,2)/10
            indexFrame = index*10;
            if ~isempty(find(p>=indexFrame,1,'first'));
                alignOnset(index)=q(find(p>=indexFrame,1,'first'));
            else
                alignOnset(index)=q(end);
            end
        end
        csvwrite(strcat(fileName,'.csv'), alignOnset);
        

    end
           
    if option.saveDropbox
        dirPiece = strsplit(dirFolder, 'sourceFiles');
        csvwrite(strcat( '/Users/Da/Dropbox/performScoreDemo', dirPiece(2) ,'/', fileName, '.csv' ),alignOnset);
    end


    if option.calError
        midiMatGT = readmidi_java(midiGTname);
        diff = calErrorKTK(midiMat, midiMatGT); 
        mean(diff)
        save(errorFileName, 'diff');
    end
    
%     alignOnset=alignOnset/sampleRate;
%     errorVector = abs(ceil(midiMatGT(:,6)'*sampleRate)  - alignOnset);
%     mean(errorVector) * (1000/sampleRate)
%     save(errorFileName, 'errorVector');

    if option.saveMIDI
        midiMat=readmidi_java(midiGTname, true);
        midiMat(:,7) = midiMat(:,7) + midiMat(:,6);
        alignOnset=zeros(1,size(midiMat,1));
        alignOffset=zeros(1,size(midiMat,1));
        onsetFrame=ceil(midiMat(:,6)*option.sampleRate);
        offsetFrame=ceil(midiMat(:,7)*option.sampleRate);
        for nOnset=1:length(alignOnset);
            if ~isempty(find(q>=onsetFrame(nOnset),1,'first'));
                alignOnset(nOnset)=p(find(q>=onsetFrame(nOnset),1,'first'));
            else
                alignOnset(nOnset)=p(end);
            end
            if ~isempty(find(q>=offsetFrame(nOnset),1,'first'));
                alignOffset(nOnset)=p(find(q>=offsetFrame(nOnset),1,'first'));
            else
                alignOffset(nOnset)=p(end);
            end

        end

        %midiMatGT = readmidi_java(midiGTname);

        midiMat(:,6) = alignOnset/option.sampleRate;
        midiMat(:,7) = alignOffset/option.sampleRate;
        midiMat(:,7) = midiMat(:,7) - midiMat(:,6);
        midiMat(midiMat(:,7)<=0, 7) = 0.1;

        saveName = strcat(fileName, '.mid');
        writemidi_seconds(midiMat, saveName);
        
        if option.saveDropbox
            dirPiece = strsplit(dirFolder, 'sourceFiles');
            writemidi_seconds(midiMat, strcat( '/Users/Da/Dropbox/performScoreDemo', dirPiece(2) ,'/', saveName ));
        end
    end
    
    


    
end

end        
        
        
        