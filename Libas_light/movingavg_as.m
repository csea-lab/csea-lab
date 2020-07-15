function [datanew] = movingavg_as(data, order)
% reads in a time series and performs moving average of order order
% data must be vector or matrix

N = size(data,2); 

datanew = data;

for index = 1:N
    if index <= N-(order-1)
    datanew(:,index) = mean(data(:,index:index+order-1), 2);
    elseif index > N-(order-1)
    datanew(:, index) = mean(data(:, index-order:end), 2);
    end
end


