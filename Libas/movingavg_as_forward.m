function [datanew] = movingavg_as_forward(data, order)
% reads in a time series and performs moving average of order order
% data must be vector or matrix

order = round(order);

N = size(data,2); 

datanew = data;

data = fliplr(datanew);

for index = 1:N
    if index <= N-(order-1)
    datanew(:,index) = mean(data(:,index:index+order-1), 2);
    elseif index > N-(order-1)
    datanew(:, index) = mean(data(:, index-order:end), 2);
    end
end

datanew(:, N-order+1) = mean(datanew(:, N-order-2:N-order+2), 2);   

datanew = fliplr(datanew);

