% app2mat
% reads emegs app file, and turns it into mat with 3 dimensions
function [outmat] = app2mat(filemat, plotflag)

for fileindex = 1: size(filemat,1)

    [Data,Version,LHeader,ScaleBins,NChan,NPoints,NTrials,SampRate,AvgRefStatus,File,Path,FilePath,EegMegStatus,NChanExtra,AppFileFormatVal]=...
        ReadAppData(deblank(filemat(fileindex,:)));
 

    outmat = zeros(size(Data,1), size(Data,2), NTrials); 
    
    for x = 1:NTrials
         [outmat(:,:,x),Version,LHeader,ScaleBins,NChan,NPoints,NTrials,SampRate,AvgRefStatus,File,Path,FilePath,EegMegStatus,NChanExtra,AppFileFormatVal]=...
        ReadAppData(deblank(filemat(fileindex,:)),x);
    
        if plotflag, plot(squeeze(outmat(:,:,x))'), title(deblank(filemat(fileindex,:))), pause(1), end
    end

eval(['save ' deblank(filemat(fileindex,:)) '.mat outmat -mat']); 

fclose('all'); pause(1); fclose('all');

end