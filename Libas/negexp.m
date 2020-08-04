function [out] = negexp(params, invec)

slope = params(1); 
intercept = params(2); 

out = exp(-invec.*slope) + intercept; 