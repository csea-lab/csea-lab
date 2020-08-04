% gaussPro.m
% this function computes a discrete Gaussian curve, where s is a row 
% vector of values and sd is the standard deviation of the Gaussian 

function gd = gaussPro(s,sd) % declare the function

gd = exp((s/sd) .^ 2 * (-0.5)); % compute the Gaussian curve

