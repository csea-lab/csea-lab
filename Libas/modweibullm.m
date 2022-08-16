function [parameters, mse] = modweibullm(M, grandmean, plotflag)

% M = n by 36 (trial) matric from alexandroperant experiment

option = statset('MaxIter', 20000, 'TolFun', 0.01,  'Robust', 'off');
xgrid = 1:length(M(1,:));

for subject = 1:size(M,1); 

disp(subject)

ind_slope =  find(abs(diff(M(subject,:)) > .2))

data4fit = (M(subject,:)' + 5.*grandmean')./6; 
%data4fit = (M(subject,:))';

 if plotflag
     hold on, plot(xgrid, data4fit, ['k']), hold off    
 end

[paras,r(subject,:),J,Sigma,mse(subject,:)]  = nlinfit(column(0:35), data4fit, @weibull, [8 .8 .5 -.1]', option);
parameters(subject,:) = real(paras);
real(paras)

    if plotflag
    line(xgrid, weibull(parameters(subject,:), xgrid), 'Color', 'r'); title(num2str(subject))
    pause(.5), clf
    end

end

