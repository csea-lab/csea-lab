function [DataMat] = atg2interpol(FileMat, targetsens, interpolsensvector)
%	interpolates targetsens by sensors in interpolsensvector
for FileIndex=1:size(FileMat,1)
	[AvgMat,File,Path,FilePath,NTrialAvgVec,StdChanTimeMat,...
	SampRate,AvgRef,Version,MedMedRawVec,MedMedAvgVec,EegMegStatus,...
    NChanExtra,TrigPoint,HybridFactor,HybridDataCell,DataTypeVal]=ReadAvgFile(deblank(FileMat(FileIndex,:)));
   
DataMat = AvgMat; 
DataMat(targetsens,:) = mean(DataMat(interpolsensvector,:), 1); 
        
        SaveAvgFile([FilePath ],DataMat,NTrialAvgVec,StdChanTimeMat, ...
        SampRate,MedMedRawVec,MedMedAvgVec,EegMegStatus,NChanExtra,TrigPoint,HybridFactor,...
        HybridDataCell)
		
	end

end
