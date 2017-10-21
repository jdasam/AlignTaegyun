dirData=cell(10,1);
dirData{1} = '/Users/Da/Public/verovioTest/sourceFiles/Bach The Well-Tempered Clavier/Book 1/846-1';
dirData{2} = '/Users/Da/Public/verovioTest/sourceFiles/Bach The Well-Tempered Clavier/Book 1/846-2';
dirData{3} = '/Users/Da/Public/verovioTest/sourceFiles/Bach The Well-Tempered Clavier/Book 1/847-1';
dirData{4} = '/Users/Da/Public/verovioTest/sourceFiles/Bach The Well-Tempered Clavier/Book 1/847-2';
dirData{5} = '/Users/Da/Public/verovioTest/sourceFiles/Chopin Barcarolle op. 60';
dirData{6} = '/Users/Da/Public/verovioTest/sourceFiles/Beethoven Piano Sonata No./8-3';
dirData{7} = '/Users/Da/Public/verovioTest/sourceFiles/Beethoven Piano Sonata No./8-1';
dirData{8} = '/Users/Da/Public/verovioTest/sourceFiles/Beethoven Piano Sonata No./14-1';
dirData{9} = '/Users/Da/Public/verovioTest/sourceFiles/Beethoven Piano Sonata No./14-3';
dirData{10} = '/Users/Da/Public/verovioTest/sourceFiles/Beethoven Piano Sonata No./23-1';
dirData{10} = '/Users/Da/Public/verovioTest/sourceFiles/Beethoven Piano Sonata No./23-3';


option = [];
option.saveMIDI = true;
option.audioToAudio = false;
option.audioExtension = 'mp3';
option.audioGTname = 'midi.mp3';
option.saveDropbox = true;

basicParameter = getDynamicRange('/Users/Da/Documents/MATLAB/midiVelocityGit/BdR2GfHc.mat');


for N=1: numel(dirData)

    dirFolder=dirData{N};

    fprintf(dirFolder);

    alignFolder_VerChromaPy2(dirFolder,option);
    getVelocityFolder(dirFolder,basicParameter, option.audioExtension);

end