function [b] = avgtseries(inmat); 

for file = 1:size(inmat,1)
   [a,File,Path,FilePath,NTrialAvgVec,StdChanTimeMat,...
	SampRate,AvgRef,Version,MedMedRawVec,MedMedAvgVec,EegMegStatus,...
    NChanExtra,TrigPoint,HybridFactor,HybridDataCell,DataTypeVal] = readavgfile(deblank(inmat(file,:))); 

        b = [];
        time = 1;
        for shift = 500:50:2200
        b(:,time) = mean(a(:, shift:shift+100),2); time = time+1;
        end;
        
        SaveAvgFile([deblank(inmat(file,:)) '.t50'] ,b,NTrialAvgVec,StdChanTimeMat, ...
    5,MedMedRawVec,MedMedAvgVec,EegMegStatus,NChanExtra,TrigPoint,HybridFactor,...
    HybridDataCell,DataTypeVal)

end
