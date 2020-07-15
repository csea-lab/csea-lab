function [dataout] = file4shahar(filemat1, outname)

dataout = []; 

for fileindex = 1:size(filemat1,1)
    
 % get a sense of how many trials there are for each pair. 
   [ Data1,Version,LHeader,ScaleBins,NChan,NPoints,NTrials1,SampRate,AvgRefStatus,File,Path,FilePath,EegMegStatus,NChanExtra,AppFileFormatVal]=...
	ReadAppDataold(deblank(filemat1(fileindex,:))); 
disp(['sample rate:'])
SampRate

datatemp = zeros([size(Data1) (NTrials1)]); 

size (datatemp)

    for trialindex = 1:NTrials1;

     [Data1,Version,LHeader,ScaleBins,NChan,NPoints,NTrials1,SampRate,AvgRefStatus,File,Path,FilePath,EegMegStatus,NChanExtra,AppFileFormatVal]=...
        ReadAppDataold(deblank(filemat1(fileindex,:)), trialindex); 

    datatemp(:,:,trialindex) = Data1; 


    end
    
    dataout = cat (3, dataout, datatemp); 
    
end
fclose('all');
eval(['save  ' outname '  dataout -mat']); 