function [datanew] = movingavg_at(filemat, order)
% reads in a time series and performs moving average of order order
% data must be vector or matrix



for fileind = 1:size(filemat,1)
    
    [data, File,Path,FilePath,NTrialAvgVec,StdMat,SampRate,AvgRef,Version,MedMedRawVec,MedMedAvgVec,...
     EegMegStatus,NChanExtra,TrigPoint,HybridFactor,HybridDataCell,DataTypeVal]=ReadAvgFile(deblank(filemat(fileind,:)));

  datanew = movmean(data,order, 2);

        
       SaveAvgFile([deblank(filemat(fileind,:)) '.mavg' num2str(order) ],datanew,[],[],SampRate,[],[],[], [], TrigPoint)
        
end % fileind

