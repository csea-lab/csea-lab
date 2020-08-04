function [BF10] = t2BF10(t,N)
% Rouder et al. page 234
% http://pcl.missouri.edu/sites/default/files/Rouder.bf_.pdf

BF10 = 1./ ( sqrt(N) .* (1+ ((t.^2)./(N-1))).^(-N/2));

