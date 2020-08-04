function [SNRspec] = getSNR_spec(filemat, noisebins)

for fileindex = 1: size(filemat,1); 
    
    [rawspec,File,Path,FilePath,NTrialAvgVec,StdChanTimeMat,...
	SampRate,AvgRef,Version,MedMedRawVec,MedMedAvgVec,EegMegStatus]=ReadAvgFile(deblank(filemat(fileindex,:))); 
    
    divmat = repmat(mean(rawspec(:, noisebins), 2), 1, size(rawspec,2)); 
    
    SNRspec  = rawspec./divmat; 
    
    SaveAvgFile([FilePath '.SNRspec'],SNRspec,NTrialAvgVec,StdChanTimeMat, ...
    SampRate,MedMedRawVec,MedMedAvgVec,EegMegStatus)
    
end


