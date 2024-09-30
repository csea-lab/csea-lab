function [amplitude] = Gaussian(beta, t)
x = t; 
% beta(1) is the mode (center)
% beta(2) is the std

center = beta(1); 
stdev = beta(2); 

amplitude = exp(-(x-center).^2/2/stdev.^2)-.5;  
