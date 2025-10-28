function [weights_samples_dimensions] = rdirichlet(number_of_dimensions, number_of_samples)
% Custom samples from Dirichlet distributions
% Useful as weights for Bayesian Bootstrap
% Parameters: shape, scale, number_of_dimensions, number_of_samples
raw_weights = gamrnd(1,1,number_of_dimensions,number_of_samples);
weights_samples_dimensions = transpose(raw_weights ./ sum(raw_weights));
