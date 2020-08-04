function [atstruc, infilemat] = readatgsindir(folder)

%reads all atgfiles into a strcuture variable atstruc, with each file as a
%substructure
infilemat = dir([folder '/*.at*']); 

for fileindex = 1:size(infilemat,1)
    
    [AvgMat,File,Path,FilePath,NTrialAvgVec,StdChanTimeMat,...
	SampRate,AvgRef,Version,MedMedRawVec,MedMedAvgVec] = ReadAvgFile(infilemat(fileindex).name);

eval(['atstruc.file' num2str(fileindex) ' = AvgMat']);
	
end
	