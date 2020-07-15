function [normtopomat] = stdtopo_at(filemat) 

for fileindex = 1:size(filemat,1); 
    
  [a,File,Path,FilePath,NTrialAvgVec,StdChanTimeMat,...
	SampRate,AvgRef,Version,MedMedRawVec,MedMedAvgVec,EegMegStatus,...
    NChanExtra,TrigPoint,HybridFactor,HybridDataCell,DataTypeVal,...
    EffectDf,ErrorDf]=ReadAvgFile(deblank(filemat(fileindex,:))); 
  normtopomat = a; 
   
   for x= 1:size(a,2); 
       normtopomat(:, x) = z_norm(a(:, x));  
   end
    
   SaveAvgFile([FilePath '.topostd'],normtopomat,NTrialAvgVec,StdChanTimeMat, ...
    SampRate,MedMedRawVec,MedMedAvgVec,EegMegStatus); 
   
end