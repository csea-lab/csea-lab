function [datanew] = movingavg_at(filemat, order, N)
% reads in a time series and performs moving average of order order
% data must be vector or matrix

if nargin < 3, 
      [data, File,Path,FilePath,NTrialAvgVec,StdMat,SampRate,AvgRef,Version,MedMedRawVec,MedMedAvgVec,...
     EegMegStatus,NChanExtra,TrigPoint,HybridFactor,HybridDataCell,DataTypeVal]=ReadAvgFile(deblank(filemat(1,:)));

        N = size(data,2); 
end
[a,b] = butter(10, 0.1); 

for fileind = 1:size(filemat,1)
    
    [data, File,Path,FilePath,NTrialAvgVec,StdMat,SampRate,AvgRef,Version,MedMedRawVec,MedMedAvgVec,...
     EegMegStatus,NChanExtra,TrigPoint,HybridFactor,HybridDataCell,DataTypeVal]=ReadAvgFile(deblank(filemat(fileind,:)));

 datanew = bslcorr(data, 1:117); 
        for index = 1:N
            if index < ceil(order./2)
           % datanew(: , index) = mean(data(:, index:index+order), 2);
           datanew(: , index) = data(:, index);
            elseif index > N - ceil(order./2)
            datanew(:, index) = data(:, index);
            else             
            datanew(:, index) = mean(data(:, index+1-floor(order./2):index+floor(order./2)), 2);
            end
        end
        
        datanew = filtfilt(a, b, datanew')'; 
        
        datanew = bslcorr(datanew, 60:117); 
        
        SaveAvgFile([deblank(filemat(fileind,:)) '.mavg' num2str(order) ],datanew,[],[],SampRate,[],[],[], [], TrigPoint)
        
end % fileind

