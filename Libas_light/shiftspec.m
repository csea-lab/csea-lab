function [AvgMat2] = shiftspec(folder, shiftbins);

infilemat = dir([folder '/*.spec*']); 

for fileindex = 1:size(infilemat,1)
    
    [AvgMat,File,Path,FilePath,NTrialAvgVec,StdChanTimeMat,...
	SampRate,AvgRef,Version,MedMedRawVec,MedMedAvgVec] = ReadAvgFile(infilemat(fileindex).name);

    
%limit time series to desired interval (timewinSP) and then apply cosine
%square window
  
    AvgMat2 = [zeros(size(AvgMat,1), shiftbins) AvgMat(:, 1:size(AvgMat,2)-shiftbins)]; 
   % AvgMat = [AvgMat zeros(257,250)]; %%%%% !!!!!!!!!!!!!!!!!!!!!!!@@@@ AAAAAARGH
   
    
       
    
    [File,Path,FilePath]=SaveAvgFile([infilemat(fileindex).name '.shift'],AvgMat2,NTrialAvgVec,StdChanTimeMat, SampRate);
	
end
	