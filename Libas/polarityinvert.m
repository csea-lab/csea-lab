function [c] = polarityinvert(filemat); 

for x = 1:size(filemat,1)

[a,File,Path,FilePath,NTrialAvgVec,StdChanTimeMat,...
	SampRate,AvgRef,Version,MedMedRawVec,MedMedAvgVec,EegMegStatus,...
    NChanExtra,TrigPoint,HybridFactor,HybridDataCell,DataTypeVal] = readavgfile(deblank(filemat(x,:))); 

c = a.*-1;  

SaveAvgFile(deblank(filemat(x,:)),c,NTrialAvgVec,StdChanTimeMat, ...
    SampRate,MedMedRawVec,MedMedAvgVec,EegMegStatus,NChanExtra,TrigPoint,HybridFactor,...
    HybridDataCell,DataTypeVal); 

end