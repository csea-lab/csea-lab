function [removed, expmod] = rm1overf(invec, freqs4exclude)

% fits an exponential to a spectrum and gets rif of 1/f

% first get rif of the alpha itself otherwise will be included in the fit
% of teh 1/f which would distort it. 

data4fit = invec; 
freqvec = 1:length(invec);
data4fit(freqs4exclude) = nan;
freqvec(freqs4exclude) = nan; 
nans = isnan(freqvec);

data4fit(nans) = interp1(freqvec(1,~nans), data4fit(1, ~nans), data4fit(1,nans), 'pchip');
    
[beta] = polyfit(1:length(invec),data4fit,3);
       
[expmod] = abs(polyval(beta, 1:length(invec)));
        
removed  = invec ./ expmod; 
        
   
   % figure, plot(invec), hold on, plot (expmod), plot(removed), hold off
    


