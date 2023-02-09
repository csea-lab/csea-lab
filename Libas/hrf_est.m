function [h] = hrf_est(BOLDvec, scanonsets, hrflength)
% bold vector needs to be row vector, scanonsets is stim onset times, as
% indices into BOLD vector 
% hrflength is a scalar (a number) indicating how many scans should be
% modeled (length of the kernel)

%first, make the design matrix
s = zeros(1,length(BOLDvec))';
s(scanonsets) = 1;

X = zeros(length(BOLDvec),hrflength);
temp = s;
for i=1:hrflength
X(:,i) = temp;
temp = [0;temp(1:end-1)];
end

% now invert design matrix X
PX = pinv(X); size(PX)

% estimate h
h = PX* BOLDvec;
