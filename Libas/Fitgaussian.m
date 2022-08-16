function [betagauss, rgauss, msegauss] = Fitgaussian(invec)

% if the max > 1, then divide by the max
invec = invec./max(invec);

% the gaussian function
% where p(1) is the mean and p(2) is the std
modelFun1 = @(p,x) exp(-(x-p(1)).^2/2/p(2).^2);  

% starting values for Gaussian
startingValsGauss = [4 1];

% do the actual Gaussian fit
[betagauss,rgauss,J,Sigma,msegauss]  = nlinfit(1:length(invec), invec, modelFun1, startingValsGauss);

% now do the DoG/Ricker fit 
%[betaDog,rDoG,J,Sigma,mse]  = nlinfit(1:length(invec), invec, Ricker, startingValsGauss);


