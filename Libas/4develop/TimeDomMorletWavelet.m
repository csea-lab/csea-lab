function [amplitude] = TimeDomMorletWavelet(beta, t)

f0 = beta(1);
sigma = beta(2);

temp = (pi^(-0.25)) * exp(2i * pi * f0 * t) .* exp(-t.^2 / (2 * sigma^2));

amplitude = real(temp); 

