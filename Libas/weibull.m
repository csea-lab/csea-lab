function [fittedvals] = weibull(params, x)

p = params; 

%p(1) = C50
%p(2) = slope
%p(3) = baseline
%p(4) = response level

fittedvals = p(3) + (1-p(3)+p(4)) .* (1-exp(-1*(x./p(1)).^p(2)));