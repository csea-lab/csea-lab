function [amplitude] = Gaussian(std, t)
x = t; 
p = [t(1) std];
amplitude = exp(-(x-p(1)).^2/2/p(2).^2)-.5;  
