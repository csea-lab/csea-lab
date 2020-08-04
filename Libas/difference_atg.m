%difference_atg
function [diffmat] = difference_atg(filemat_1, filemat_2, outnamebase); 

 
for index = 1:size(filemat_1,1) 
    
    [AvgMat1,File,Path,FilePath,NTrialAvgVec,StdMat,SampRate,AvgRef,Version,MedMedRawVec,MedMedAvgVec,...
     EegMegStatus,NChanExtra,TrigPoint,HybridFactor,HybridDataCell,DataTypeVal]=ReadAvgFile(deblank(filemat_1(index,:)));
 
   [AvgMat2,File,Path,FilePath,NTrialAvgVec,StdMat,SampRate,AvgRef,Version,MedMedRawVec,MedMedAvgVec,...
     EegMegStatus,NChanExtra,TrigPoint,HybridFactor,HybridDataCell,DataTypeVal]=ReadAvgFile(deblank(filemat_2(index,:)));
 
 diffmat = AvgMat1 - AvgMat2; 
 
 SaveAvgFile([outnamebase '_' num2str(index) '.atg.diff.ar' ],diffmat,NTrialAvgVec,[],SampRate,MedMedRawVec,MedMedAvgVec,EegMegStatus); 
 
end