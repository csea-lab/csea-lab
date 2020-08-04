function [data_hat] = logwithintercept(params, data_in)
%log function for fitting
% params(1) = slope
% params (2) = intercept
data_hat = params(1).* log(data_in+1) + params(2); 

