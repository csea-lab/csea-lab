function [outputArg1,outputArg2] = bootstrap2BF(dist1,dist2, plotflag)
% This function takes two bootstrapped distributions (>1000 draws needed)
% dist1 and dist2, which reflect an effect model (dist1) and a null model
% (dist2). It computes then the BF as posterior oddsover prior odds foe the
% model entering the bootstrap in dist1. in many cases dist2 will be a
% permutation distribution representing the null model. 
% dist1 and dist2 are vectors

PD1 = fitdist(column(dist1),'normal');
PD2 = fitdist(column(dist2),'normal');

x_values = -6:.01:6;
y1 = pdf(PD1,x_values);

if plotflag 


end

