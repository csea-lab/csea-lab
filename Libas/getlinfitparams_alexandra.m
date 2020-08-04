function [ fitslopintercept ] = getlinfitparams_alexandra( inmat )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

outmat = []; tempdelta =[];
for sub = 1:122, 
    [outmat(sub,:), s] = polyfit(1:16, inmat(sub,1:16),1); 
    [y,tempdelta(sub,:)] = polyval(outmat(sub,:),1:16, s); 
    plot(y), hold on, plot(inmat(sub,1:16), 'o'), title(num2str(sub)), axis([1 16 0 100]); 
    fit = corr(y', inmat(sub,1:16)'); 
    fitslopintercept(sub,:) = [fit outmat(sub,:)]
    hold off, pause(.1), 
end


