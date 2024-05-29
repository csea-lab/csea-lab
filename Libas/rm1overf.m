function [removed, expmod] = rm1overf(invec, freqs4exclude, methodflag)

% fits an exponential to a spectrum and gets rif of 1/f
% or fits a quadratic
% first get rif of the alpha itself otherwise will be included in the fit
% of teh 1/f which would distort it. 

% this is shared between the two fitting methods
data4fit = invec;
freqvec = 1:length(invec);
data4fit(freqs4exclude) = nan;
nans = isnan(data4fit);

if methodflag == 1
    % define 1/f function with intercept
    modelfun = @(beta,x) beta(1) + beta(2) .* 1./x;
    betavec = nlinfit(1:length(data4fit), data4fit, modelfun, [1 1]);
    % apply the best fitting beta
    expmod = modelfun(betavec, 1:length(data4fit));

elseif methodflag == 2

    % use a quad polyfit instead
    data4fit(nans) = interp1(freqvec(1,~nans), data4fit(1, ~nans), freqvec(1,nans), 'pchip');
    [beta] = polyfit(1:length(invec),data4fit,3);
    [expmod] = abs(polyval(beta, 1:length(invec)));

end
        
removed  = invec ./ expmod; 
       
    


