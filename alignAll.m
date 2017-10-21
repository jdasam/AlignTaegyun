dirData=cell(10,1);
dirData{1} = '/Users/Da/Public/verovioTest/Schumann';




option = [];
option.saveMIDI = true;
option.audioToAudio = false;
option.audioExtension = 'mp3';
option.audioGTname = 'midi.mp3';
option.saveDropbox = true;

basicParameter = getDynamicRange('/Users/Da/Documents/MATLAB/midiVelocityGit/BdR2GfHc.mat');


for N=1: numel(dirData)
    dirTarget=dirData{N};
    targets=dir(dirTarget);
    for n=1:numel(targets);
        if targets(n).isdir==1 && not(strcmp(targets(n).name,'.')) && not(strcmp(targets(n).name,'..'));
            folderName=targets(n).name;
            dirFolder=fullfile(dirTarget,folderName);

            fprintf(dirFolder);
            
            alignFolder_VerChromaPy2(dirFolder,option);
            getVelocityFolder(dirFolder,basicParameter, option.audioExtension);
            
        end
    end
end