function [datanew] = movingavg_flip(data, order)
% reads in a time series and performs moving average of order order
% data must be vector or matrix

N = size(data,2); 

datanew = data;

for index = 1:N-order  
    datanew(:, index) = mean(data(:, index:index+order), 2);
end


% and now redo with flipped signal
data = fliplr(datanew);

datanew = data;

for index = 1:N-order 
    datanew(:,index) = mean(data(:,index:index+order-1), 2);
end


datanew = fliplr(datanew);


 