% Rayleightest_movwin.m
function [pvals, Rs] = Rayleightest(filemat, Nwindows)
% this claculates p values based on rayleigh (PLI) values in the at format
% file, works only with moving averages, because the number of windows
% shifted is known and typically constant
% filemat is alist of files tat have PLI values (1 topography each) 

for fileindex = 1: size(filemat,1)
    a = readavgfile(deblank(filemat(fileindex,:))); 
    
    n = Nwindows; 
    Rbar = a; 
    
    Z = n*Rbar.^2;
    pvals = exp(-Z) .* (1 + (2.*Z - Z.^2) / (4.*n) - (24.*Z - 132.*Z.^2 + 76.*Z.^3 - 9.*Z.^4) / (288.*n.^2));
       
    
    SaveAvgFile([deblank(filemat(fileindex,:)) '.PLIps' ],pvals,[],[],1,[],[],[])
       
  
end


