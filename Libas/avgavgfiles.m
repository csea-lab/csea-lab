function [avgmat] = avgavgfiles(filemat, outname) 

if nargin < 2
    outmat = []; 
end

avgmat = []; 

for index = 1:size(filemat,1)
    
     [AvgMat,File,Path,FilePath,NTrialAvgVec,StdMat,SampRate,AvgRef,Version,MedMedRawVec,MedMedAvgVec,...
     EegMegStatus,NChanExtra,TrigPoint,HybridFactor,HybridDataCell,DataTypeVal]=ReadAvgFile(deblank(filemat(index,:)));
 

         if index ==1 
             avgmat = AvgMat; 

         else
             avgmat = avgmat + AvgMat; 

         end 

end

avgmat = avgmat ./ index; 

 if ~isempty(outmat)
    SaveAvgFile(outname,avgmat,NTrialAvgVec,StdMat,SampRate,MedMedRawVec,MedMedAvgVec,...
    EegMegStatus,NChanExtra,TrigPoint,HybridFactor,HybridDataCell,DataTypeVal);
 end