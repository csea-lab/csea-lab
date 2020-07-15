function [] = appendavgfiles(filemat)

AppendAvgMat = []; 

for fileind = 1:size(filemat,1); 
    
     [AvgMat,File,Path,FilePath,NTrialAvgVec,StdMat,SampRate,AvgRef,Version,MedMedRawVec,MedMedAvgVec,...
     EegMegStatus,NChanExtra,TrigPoint,HybridFactor,HybridDataCell,DataTypeVal]=ReadAvgFile(deblank(filemat(fileind,:)));
 
 AppendAvgMat = [AppendAvgMat AvgMat]; 
 
 
end


SaveAvgFile([deblank(filemat(1,:)) '.' num2str(size(filemat,1)) 'apd'],AppendAvgMat,[],[],1,[],[]);