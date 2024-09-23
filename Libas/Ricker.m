function [amplitude] = Ricker(std, t)

% t represents the number of conditions or the time points

% Parameter
Fc = std; % standard deviation or Difference-of-Gaussian width

p = Fc.*Fc.*t.*t; % squared values
amplitude = ((1-2*pi*pi.*p).*exp(-pi*pi.*p))';
