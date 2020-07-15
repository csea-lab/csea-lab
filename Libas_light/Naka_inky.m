function [parameters] = Naka_inky(hitvector,thex,startingVals, colorname); 

% hitvector = percentage divided by 100, i.e. bounded between 0 and 1 
% thex =contrast levels used in experiment
% enter hitvector, thex, and startingVals as ROW vectors, they are flipped
% below

% EXAMPLES: 
%thex = [0  1.3400    1.8100    2.4500    3.3000    4.4600    6.0200    8.1200   10.9700]
% startingVals = [ 0.5 0.5 1 3]

%Code starts here: 
%uncomment weibull or naka-rushton

% the weibull function
%modelFun = @(p,x) p(3) + (1-p(3)-p(4)) .* (1-exp(-1*(x./p(1)).^p(2)));

% Naka-Rushton equation: p(1) = a = response amplitude parameter
% (multiplicative), p(2) = b = baseline response level, p(3) = n = exponent
% determining the slope of the contrast response function, p(4) = C50 =
% semisaturation constant
modelFun = @(p,x) ( p(1).*( (x.^p(3))./(x.^p(3) + p(4).^p(3)) ) ) + p(2);

option = statset('MaxIter', 10000, 'TolFun', 0.00001,  'Robust', 'on')

% do the actual fit
[parameters,r,J,Sigma,mse]  = nlinfit(thex', hitvector', modelFun, startingVals', option);

% plot the results
xgrid = linspace(0,11,100);

line(xgrid, modelFun(parameters, xgrid), 'Color', colorname);
hold on
plot(thex, hitvector, ['*' colorname]), hold off

