function [diffmat] = diffERP(filename1, filename2, outname); 

[a,File,Path,FilePath,NTrialAvgVec,StdChanTimeMat,...
	SampRate,AvgRef,Version,MedMedRawVec,MedMedAvgVec,EegMegStatus,...
    NChanExtra,TrigPoint,HybridFactor,HybridDataCell,DataTypeVal] = readavgfile(filename1); 
b = readavgfile(filename2);

c = a - b; 

SaveAvgFile(outname,c,NTrialAvgVec,StdChanTimeMat, ...
    SampRate,MedMedRawVec,MedMedAvgVec,EegMegStatus,NChanExtra,TrigPoint,HybridFactor,...
    HybridDataCell,DataTypeVal); 
