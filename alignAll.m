dirData=cell(10,1);
dirData{1} = '/Users/Da/Public/verovioTest/Schumann';



for N=1: numel(dirData)
    dirTarget=dirData{N};
    targets=dir(dirTarget);
    for n=1:numel(targets);
        if targets(n).isdir==1 && not(strcmp(targets(n).name,'.')) && not(strcmp(targets(n).name,'..'));
            folderName=targets(n).name;
            dirFolder=fullfile(dirTarget,folderName);

            fprintf(dirFolder);
            
            alignFolder_VerChromaPy2(dirFolder);
        end
    end
end