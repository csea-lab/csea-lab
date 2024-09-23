function [amplitude] = TimeDomMorletWavelet(beta, t)

% t represents the number of conditions or the time points

% Parameters
f0 = beta(1); % center frequency 
sigma = beta(2); % standard deviation

temp = ((pi^(-0.25)) .* exp(2i * pi * f0 * t) .* exp(-t.^2 / (2 * sigma^2)))';

amplitude = real(temp); 

