dirTarget=fullfile(cd,'SMDTEST');
targets=dir(dirTarget);
for n=1:numel(targets);
    if targets(n).isdir==1 && not(strcmp(targets(n).name,'.')) && not(strcmp(targets(n).name,'..'));
        folderName=targets(n).name;
        dirFolder=fullfile(dirTarget,folderName);
        sampleRate=20;
        
        dirScoreAudio=fullfile(dirFolder,'score.mp3');
        scoreFBR=prepareAudio(dirScoreAudio,sampleRate);
        
        dirScoreMidi=fullfile(dirFolder,'score.mid');
        scoreMidiMat=readmidi_java(dirScoreMidi);
        scoreMidiNoteMat=midiMat2NoteMat(scoreMidiMat,sampleRate);
        
        dirTargetAudio=fullfile(dirFolder,'target.mp3');
        targetFBR=prepareAudio(dirTargetAudio,sampleRate);
        
        dirTargetMidi=fullfile(dirFolder,'target.mid');
        targetMidiMat=readmidi_java(dirTargetMidi);
        targetMidiNoteMat=midiMat2NoteMat(targetMidiMat,sampleRate);
        
        cosineSimilarityMidi=simmx(scoreMidiNoteMat+1e-6,targetMidiNoteMat+1e-6);
        [p,q,~,~] = dpfast(1-cosineSimilarityMidi);
        alignOnsetMidi=zeros(1,size(scoreMidiMat,1));
        onsetFrame=round(scoreMidiMat(:,6)*sampleRate);
        for nOnset=1:length(alignOnsetMidi);
            alignOnsetMidi(nOnset)=q(find(p>=onsetFrame(nOnset),1,'first'));
        end
        alignOnsetMidi=alignOnsetMidi/sampleRate;
        dirDTWPath=fullfile(dirFolder,'midiDTW.mat');
        save(dirDTWPath,'p','q');
        
        cosineSimilarityTarget=simmx(scoreFBR,targetFBR);
        [p,q,~,~] = dpfast(1-cosineSimilarityTarget);
        alignOnsetTarget=zeros(1,size(scoreMidiMat,1));
        onsetFrame=round(scoreMidiMat(:,6)*sampleRate);
        for nOnset=1:length(alignOnsetMidi);
            alignOnsetTarget(nOnset)=q(find(p>=onsetFrame(nOnset),1,'first'));
        end
        alignOnsetTarget=alignOnsetTarget/sampleRate;
        dirDTWPath=fullfile(dirFolder,'FBRDTW.mat');
        save(dirDTWPath,'p','q');
        
        error=alignOnsetTarget-alignOnsetMidi;
        errorMean=mean(abs(error));
        errorMax=max(abs(error));
        errorSTD=std(error);
        dirError=fullfile(dirFolder,'error.mat');
        save(dirError,'error','errorMean','errorMax','errorSTD');
    end
        
end

N=1;
for n=1:numel(targets);
    if targets(n).isdir==1 && not(strcmp(targets(n).name,'.')) && not(strcmp(targets(n).name,'..'));
        folderName=targets(n).name;
        dirFolder=fullfile(dirTarget,folderName);
        dirError=fullfile(dirFolder,'error.mat');
        load(dirError);
        errorStruct(N).name=folderName;
        error=error-mean(error);
        errorStruct(N).errorMean=mean(abs(error));
        errorStruct(N).errorMax=max(abs(error));
        errorStruct(N).errorSTD=std(error);
        errorStruct(N).ratio01=sum(abs(error)<0.1)/length(error);
        errorStruct(N).ratio02=sum(abs(error)<0.2)/length(error);
        errorStruct(N).ratio03=sum(abs(error)<0.3)/length(error);
        errorStruct(N).ratio04=sum(abs(error)<0.4)/length(error);
        errorStruct(N).ratio05=sum(abs(error)<0.5)/length(error);
        errorStruct(N).ratio10=sum(abs(error)<1)/length(error);
        N=N+1;
    end
end