function [outvec] = TimeDomMorletWavelet(f0, sigma, t)


amplitude = (pi^(-0.25)) * exp(2i * pi * f0 * t) .* exp(-t.^2 / (2 * sigma^2));

outvec = real(amplitude); 

