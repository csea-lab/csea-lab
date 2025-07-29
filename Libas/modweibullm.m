function [parameters, mse] = modweibullm(M, grandmean, plotflag)

% M = n by 36 (trial) matric from alexandroperant experiment

option = statset('MaxIter', 20000, 'TolFun', 0.01,  'Robust', 'off'); % these are the options fro nonlinfit
xgrid = 1:length(M(1,:));

for subject = 1:size(M,1)

 clf

disp('subject: '), disp(subject)

data4fit = (M(subject, :) + grandmean)./2; 

data4fit = data4fit./max(data4fit); % !!!

 if plotflag
     hold on, plot(xgrid, data4fit, 'k'), hold off    
 end

[paras,r(subject,:),J,Sigma,mse(subject,:)]  = nlinfit(column(0:35), column(data4fit), @weibull, [6 .8 .5 -.1]', option);
parameters(subject,:) = real(paras);
real(paras); 

    if plotflag
    line(xgrid, weibull(parameters(subject,:), xgrid), 'Color', 'r'); title(num2str(subject))
    pause(.5)
    end

end

