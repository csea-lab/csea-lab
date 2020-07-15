function [DataMat] = atg2cosinwin(FileMat, winrampSP)
%	interpolates targetsens by sensors in interpolsensvector
for FileIndex=1:size(FileMat,1)
	
    [AvgMat,File,Path,FilePath,NTrialAvgVec,StdChanTimeMat,...
	SampRate,AvgRef,Version,MedMedRawVec,MedMedAvgVec,EegMegStatus,...
    NChanExtra,TrigPoint,HybridFactor,HybridDataCell,DataTypeVal]=ReadAvgFile(deblank(FileMat(FileIndex,:)));
   
AvgMat = AvgMat;

 [cosinwinmat] = cosinwin(winrampSP,size(AvgMat,2), size(AvgMat,1));

DataMat  = cosinwinmat.*AvgMat; 
        
        SaveAvgFile([deblank(FileMat(FileIndex,1:end-7))],DataMat,NTrialAvgVec,StdChanTimeMat, ...
        SampRate,MedMedRawVec,MedMedAvgVec,EegMegStatus,NChanExtra,TrigPoint,HybridFactor,...
        HybridDataCell)
		
	end

end
