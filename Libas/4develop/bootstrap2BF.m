function [] = bootstrap2BF(dist1,dist2, plotflag)
% This function takes two bootstrapped distributions (>1000 draws needed)
% dist1 and dist2, which reflect an effect model (dist1) and a null model
% (dist2). It computes then the BF as posterior oddsover prior odds foe the
% model entering the bootstrap in dist1. in many cases dist2 will be a
% permutation distribution representing the null model. 
% dist1 and dist2 are vectors

% fit the bootstrapped distributions as normal distributions
PD1 = fitdist(column(dist1),'normal');
PD2 = fitdist(column(dist2),'normal');

% apply the normal distributions
x_values = -8:.01:8;
y1 = pdf(PD1,x_values);
y2 = pdf(PD2,x_values);

% plot for control, then turn off plotflag
if plotflag 
subplot(2,1,1), histogram(dist1, 100, 'Normalization','pdf')
hold on
plot(x_values, y1, 'LineWidth',3)

subplot(2,1,2), histogram(dist2, 100, 'Normalization','pdf')
hold on
plot(x_values, y2, 'LineWidth',3)
end

