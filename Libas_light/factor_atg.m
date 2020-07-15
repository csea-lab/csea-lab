%difference_atg
function [AvgMat1] = factor_atg(filemat, factor, range); 

 
for index = 1:size(filemat,1) 
    
    [AvgMat1,File,Path,FilePath,NTrialAvgVec,StdMat,SampRate,AvgRef,Version,MedMedRawVec,MedMedAvgVec,...
     EegMegStatus,NChanExtra,TrigPoint,HybridFactor,HybridDataCell,DataTypeVal]=ReadAvgFile(deblank(filemat(index,:)));

 
%AvgMat1(:, 6:10)  = AvgMat1(:, 6:10)  + factor; 
 AvgMat1([70 75 83 74 82 81], range)  = AvgMat1([70 75 83 74 82 81], range)  + factor; 
 % AvgMat1([88 89 94], range)  = AvgMat1([88 89 94], range)  + factor; 
  AvgMat1(:, range)  = AvgMat1(:, range)  + rand(1,1)/20; 
 
 SaveAvgFile([deblank(filemat(index,:)) ],abs(AvgMat1),NTrialAvgVec,[],SampRate,MedMedRawVec,MedMedAvgVec,EegMegStatus); 
 
end