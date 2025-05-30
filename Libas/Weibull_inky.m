function [beta, r, J] = Weibull_inky(hitvector); 

% hitvector = percentage divided by 100, i.e. bounded between 0 and 1 
% first define log of contrast levels used in experiment
thex = log(round(exp(4.5:.43:7.7))./100)+.2; 

% we need the weibull function
%modelFun =  @(p,x) p(3) .* (x ./ p(1)).^(p(2)-1) .* exp(-(x ./ p(1)).^p(2));
modelFun = @(p,x) p(3) + (1-p(3)-p(4)) .* (1-exp(-1*(x./p(1)).^p(2)));

% and starting values
startingVals = [2 2 .5 0.1];

% do the actual fit
[beta,r,J,Sigma,mse]  = nlinfit(thex, hitvector, modelFun, startingVals);

% plot the results
xgrid = linspace(0,3.2,100);

line(xgrid, modelFun(beta, xgrid), 'Color','r');
hold on
plot(thex, hitvector, '*')



