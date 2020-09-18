% app2mat
% reads emegs app file, and turns it into mat with 3 dimensions
function [AvgMat] = app2atg(filemat, plotflag)

for fileindex = 1: size(filemat,1)
    
    FilePath = deblank(filemat(fileindex,:));
   
                [Data,Version,LHeader,ScaleBins,NChan,NPoints,NTrials,SampRate,AvgRefStatus,File,Path,FilePath,EegMegStatus,NChanExtra,AppFileFormatVal]=...
                ReadAppData(FilePath);
            
                for x = 1:NTrials
                     [outmat(:,:,x),Version,LHeader,ScaleBins,NChan,NPoints,NTrials,SampRate,AvgRefStatus,File,Path,FilePath,EegMegStatus,NChanExtra,AppFileFormatVal]=...
                    ReadAppData(FilePath,x);
                    if plotflag, figure(10), hold on, plot(squeeze(outmat(:,:,x))', 'r'), pause(.5), end
                end

                FilePathOut = [FilePath '.at.ar']
                
                AvgMat = mean(outmat,3);
                
                 if plotflag, figure(10), plot(AvgMat', 'b'), pause(.5), hold off, end
                
                 SaveAvgFile(FilePathOut,AvgMat,[],[], SampRate,[],[],[],[],117);          
                
                fclose('all'); pause(1); fclose('all');
                
end