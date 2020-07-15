function [datanew] = movingavg_2ndord(data)
% reads in a time series and performs moving average of order order
% data must be vector or matrix

N = size(data,2); 

for index = 1:N
    if index ==1 
    datanew(:,1) = data(:,1);
    elseif index > 1 && index < N 
    datanew(:, index) = mean(data(:, index-1:index), 2);
     elseif index ==N 
    datanew(:, index) = data(:,N);
    end
end


