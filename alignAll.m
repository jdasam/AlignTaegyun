dirData=cell(10,1);
dirData{1} = '/Users/Da/Public/verovioTest/sourceFiles/Chopin Waltzes op.';
dirData{2} = '/Users/Da/Public/verovioTest/sourceFiles/Chopin Etude op. 25';
dirData{3} = '/Users/Da/Public/verovioTest/sourceFiles/Chopin Ballades No.';
dirData{4} = '/Users/Da/Public/verovioTest/sourceFiles/Schumann Kinderszenen Op.15';
dirData{5} = '/Users/Da/Public/verovioTest/sourceFiles/Schubert 3 Klavierstucke D.946';
dirData{6} = '/Users/Da/Public/verovioTest/sourceFiles/Liszt/Libestraum S.541 No.3';



option = [];
option.saveMIDI = true;
option.audioToAudio = false;
option.audioExtension = 'mp3';
option.audioGTname = 'midi.mp3';    
option.saveDropbox = true;

[B, basicParameter] = getDynamicRange('/Users/Da/Documents/MATLAB/midiVelocityGit/BdR2GfHc.mat');


for N=1: numel(dirData)
    dirTarget=dirData{N};
    targets=dir(dirTarget);
    for n=1:numel(targets);
        if targets(n).isdir==1 && not(strcmp(targets(n).name,'.')) && not(strcmp(targets(n).name,'..'));
            folderName=targets(n).name;
            dirFolder=fullfile(dirTarget,folderName);


                    dirPiece = strsplit(dirFolder, 'sourceFiles');
                    mkdir(strcat( '/Users/Da/Dropbox/performScoreDemo', dirPiece{2}))

                    fprintf(dirFolder);

                    alignFolder_VerChromaPy2(dirFolder,option);
                    getVelocityFolder(dirFolder,B, basicParameter, option.audioExtension);

            
        end
    end
end