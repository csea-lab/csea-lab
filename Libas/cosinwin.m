% cosinwin
% creates a window function with ramp M at the beginning and the end, for
% total length N and with nrows repetitions for application to a matrix if
% needed
% 
function [cosinwinmat] = cosinwin(M,N, nrows)
M = round(M);
N = round(N);

if nargin < 3, nrows = 1; end

    squarecos1 = (cos(pi/2:(pi-pi/2)/M:pi-(pi-pi/2)/M)).^2;
	
	squarecosfunction = [squarecos1 ones(1,N-M*2) fliplr(squarecos1)];
	
	%figure(1), plot(squarecosfunction)
    
    cosinwinmat = repmat(squarecosfunction, nrows,1); 



