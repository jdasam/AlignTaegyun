dirData=cell(6,1);
dirData{1}='/home/jdasam/Documents/MATLAB/projectFiles/Bach Invention & Sinfonia/Invention BWV 772-786';
dirData{2}='/home/jdasam/Documents/MATLAB/projectFiles/Bach Invention & Sinfonia/Sinfonia BWV 787-801/';
dirData{3}='/home/jdasam/Documents/MATLAB/projectFiles/Bach Italian Concerto BWV 971';
dirData{4}='/home/jdasam/Documents/MATLAB/projectFiles/Bach The Well-Tempered Clavier/Book 1/';    
dirData{5}='/home/jdasam/Documents/MATLAB/projectFiles/Bach The Well-Tempered Clavier/Book 2/';
dirData{6}='/home/jdasam/Documents/MATLAB/projectFiles/Beethoven Piano Sonatas';

errorList=struct;
N=1;

for N=1:numel(dirData);
    dirTarget=dirData{N};
    targets=dir(dirTarget);
    for n=1:numel(targets);
        if targets(n).isdir==1 && not(strcmp(targets(n).name,'.')) && not(strcmp(targets(n).name,'..'));
            folderName=targets(n).name;
            dirFolder=fullfile(dirTarget,folderName);
            
            dirMidi=fullfile(dirFolder,'(midi).mid');
            midiMat=readmidi_java(dirMidi);
            midiMat(:,8)=midiMat(:,6)+midiMat(:,7);
            lastSecMidi=max(midiMat(:,8));
            
            dirScoreAudio=fullfile(dirFolder,'midi.mp3');
            [audio,sr]=audioread(dirScoreAudio);
            lastSecAudio=length(audio)/sr;
            
            if abs(lastSecMidi-lastSecAudio)>1;
                errorList(N).name=folderName;
                errorList(N).dir=dirFolder;
                errorList(N).diff=lastSecMidi-lastSecAudio;
                N=N+1;
            end
            
        end
    end
end
save('/home/jdasam/Score Alignment/midiError2.mat','errorList');