function [BF] = bootstrap2BF_z(dist1,dist2, plotflag)
% This function takes two bootstrapped distributions (>1000 draws needed)
% dist1 and dist2, which reflect an effect model (dist1) and a null model
% (dist2). It computes then the BF as posterior odds over prior odds for the
% model entering the bootstrap in dist1. in many cases dist2 will be a
% permutation distribution representing the null model. 
% dist1 and dist2 are vectors

% to avoid issues with scaling, do a joint z-normalization of both
% bootstrapped distributions together, thus maintaining any differences in
% mean and spread

dist1 = column(dist1); % make sure they are column vectors
dist2 = column(dist2);


temp = z_norm([dist1; dist2]);

dist1z = temp(1:length(dist1));
dist2z =temp(length(dist1)+1:end);


% fit the bootstrapped distributions as normal distributions
PD1 = fitdist(column(dist1z),'normal');
PD2 = fitdist(column(dist2z),'normal');

% apply the normal distributions
x_values = -5:.01:5;
y1 = pdf(PD1,x_values);
y2 = pdf(PD2,x_values);

% plot for control, then turn off plotflag
if plotflag 
subplot(2,1,1), histogram(dist1z, 100, 'Normalization','pdf')
hold on
plot(x_values, y1, 'LineWidth',3)
xline(0)

subplot(2,1,2), histogram(dist2z, 100, 'Normalization','pdf')
hold on
plot(x_values, y2, 'LineWidth',3)
xline(0)
end

posteriorsignedlikelyhood_effect = sum(y1(x_values > 0))./100;
signedlikelyhood_null = sum(y2(x_values > 0))./100;

odds_posterior = posteriorsignedlikelyhood_effect ./(1-posteriorsignedlikelyhood_effect);
odds_prior = signedlikelyhood_null ./(1-signedlikelyhood_null);
    

BF = odds_posterior/odds_prior; 
