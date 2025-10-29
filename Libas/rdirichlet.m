function [weights_samples_dimensions] = rdirichlet(number_of_dimensions, number_of_samples)
% Custom samples from Dirichlet distributions
% Useful as weights for Bayesian Bootstrap
% Parameters: shape, scale, number_of_dimensions, number_of_samples
raw_weights = gamrnd(1,1,number_of_dimensions,number_of_samples);
weights_samples_dimensions = transpose(raw_weights ./ sum(raw_weights));

% If you uncomment the below code the function will break
% % Example: posterior of two simulated groups' means
% % followed by a posterior contrast of the group means
% % to show the probability of difference

% % 100 participants drawn from a normal distribtion mean = 0, sd = 1
% number_sample_1_participants = 100;
% sample_1 = normrnd(0,1,number_sample_1_participants,1);
% % 100 participants drawn from a normal distribtion mean = 1, sd = 1
% number_sample_2_participants = 100;
% sample_2 = normrnd(1,1,number_sample_2_participants,1);

% % 2000 samples from a Dirichlet with a weight for each participant
% % each row sums to 1
% number_posterior_samples = 2000;
% sample_1_weights = rdirichlet(number_sample_1_participants, ...
%     number_posterior_samples);

% sample_2_weights = rdirichlet(number_sample_2_participants, ...
%     number_posterior_samples);

% % matrix multiplication gives a weighted average per sample
% % The weights have to be used differently if the goal is
% % a posterior of some other value like variance or cross-validation
% % accuracy
% bayesboot_posterior_sample_1_mean = sample_1_weights * sample_1;
% bayesboot_posterior_sample_2_mean = sample_2_weights * sample_2;

% % The probability / posterior of what the difference between
% % the two groups means is found through a posterior contrast,
% % which is subtracting across the posterior samples of each
% % group mean. So number of posterior samples has to be the same
% % between groups, not number of participants / dimensions.
% posterior_mean_diff = bayesboot_posterior_sample_2_mean - bayesboot_posterior_sample_1_mean;

% % Visualize the posteriors
% histogram(bayesboot_posterior_sample_1_mean)
% histogram(bayesboot_posterior_sample_2_mean)
% histogram(posterior_mean_diff)

% % Report median and 95% credibility intervals
% quantile(bayesboot_posterior_sample_1_mean,[.025, .5, .975])
% quantile(bayesboot_posterior_sample_2_mean,[.025, .5, .975])
% quantile(posterior_mean_diff,[.025, .5, .975])

% % A test of "statistical significance" is the probability above or below
% % zero for a posterior contrast. Zero posterior samples are below zero,
% % so the probability of group two's mean is smaller than group one is
% % zero. If 100 of 2000 where below zero it would be 5% probability.
% (sum(posterior_mean_diff < 0))/number_posterior_samples



