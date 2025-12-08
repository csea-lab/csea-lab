function [BF] = bootstrap2BF_nonparam(theta1,theta2, plotflag)
% This function takes two bootstrapped distributions (>1000 draws needed)
% dist1 and dist2, which reflect two variables atht we wish to compare, eg experimental conditions.
% It computes then the BF as posterior oddsover prior odds (odds =1, p = 0.5 is default)
% dist1 and dist2 are vectors
% outputs: 
%  BF Bayes factor for H: θ1 > θ2  (with bootstrap uncertainty)
% inputs:
%  theta1, theta2 = posterior samples (same length)
%% 

% INPUT: posterior draws (replace these with your variables)
% theta1 = ...;
% theta2 = ...;

% Make them column vectors
theta1s = theta1(:);
theta2s = theta2(:);

N1 = numel(theta1s);
N2 = numel(theta2s);
if N1== N2, N = N1; 
else 
    error('input distributions need to have same size')
end

%% before starting, compute the credible intervals of the input distributions: 
% Credible intervals (95%) for θ1 and θ2
CI_theta1 = prctile(theta1s, [2.5 97.5]);
CI_theta2 = prctile(theta2s, [2.5 97.5]);

% Summary statistics
mean_theta1 = mean(theta1s);
mean_theta2 = mean(theta2s);
median_theta1 = median(theta1s);
median_theta2 = median(theta2s);

% Difference distribution
theta_diff = theta1s - theta2s;
CI_diff = prctile(theta_diff, [2.5 97.5]);
mean_diff = mean(theta_diff);
median_diff = median(theta_diff);

%% Step 1: compute the posterior probability P(H | data)
p_post = mean(theta1s > theta2s);

%% Step 2: compute or set the prior probability P(H)
% If the priors are symmetric and independent, this is 0.5. -> odds = 1
% Otherwise set simulate_prior = true and define your priors.
simulate_prior = false;

if simulate_prior
    Nprior = 1e5;
    
    % *** CHANGE THESE to your actual priors ***
    % Example: Normal(0,1) for both
    theta1_prior = randn(Nprior,1);
    theta2_prior = randn(Nprior,1);

    p_prior = mean(theta1_prior > theta2_prior);
else
    p_prior = 0.5;
end

%% Step 3: compute Bayes factor - this is NOT the log or log10!!!
odds_post  = p_post / (1 - p_post);
odds_prior = p_prior / (1 - p_prior);
BF = odds_post / odds_prior;

%% Step 4: compute the Bootstrap BF uncertainty
B = 2000;                 % number of bootstrap replicates
BF_boot = zeros(B,1);

for b = 1:B
    idx = randi(N, N, 1);     % bootstrap resample indices
    p_post_b = mean(theta1s(idx) > theta2s(idx));
    odds_post_b = p_post_b / (1 - p_post_b);
    BF_boot(b) = odds_post_b / odds_prior;
end

BF_CI = prctile(BF_boot, [2.5 97.5]);

%% Step 5: dusplay detailed results, for now just in command window
fprintf('-----------------------------------------\n');
fprintf('Results of the comparisons\n');
fprintf('Posterior P(θ1 > θ2): %.4f\n', p_post);
fprintf('Prior     P(θ1 > θ2): %.4f\n', p_prior);
fprintf('Bayes Factor (BF):    %.4f\n', BF);
fprintf('95%% bootstrap CI for BF: [%.4f, %.4f]\n', BF_CI(1), BF_CI(2));
fprintf('-----------------------------------------\n');
fprintf('Properties of the input distributions:\n');
fprintf('θ1 mean:    %.4f, median: %.4f, 95%% CI: [%.4f, %.4f]\n', ...
        mean_theta1, median_theta1, CI_theta1(1), CI_theta1(2));

fprintf('θ2 mean:    %.4f, median: %.4f, 95%% CI: [%.4f, %.4f]\n', ...
        mean_theta2, median_theta2, CI_theta2(1), CI_theta2(2));

fprintf('(θ1 - θ2) difference:\n');
fprintf('  mean: %.4f, median: %.4f, 95%% CI: [%.4f, %.4f]\n', ...
        mean_diff, median_diff, CI_diff(1), CI_diff(2));
fprintf('-----------------------------------------\n\n');

%% optional plot: overlaid histograms of the two posterior distributions
if plotflag
    figure; hold on;

    histogram(theta1s, 'Normalization', 'pdf', ...
        'FaceAlpha', 0.4, 'EdgeColor', 'none');
    histogram(theta2s, 'Normalization', 'pdf', ...
        'FaceAlpha', 0.4, 'EdgeColor', 'none');

    xlabel('\theta value');
    ylabel('Density');
    legend({'Posterior \theta_1', 'Posterior \theta_2'}, 'Location', 'best');
    title('Posterior Distributions of \theta_1 and \theta_2');
    grid on;

end
