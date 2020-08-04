function xLag = lagGen(x,lags)
%lagGen Lag generator.
%   [XLAG] = LAGGEN(X,LAGS) returns the matrix XLAG containing the lagged
%   time series of X for a range of time lags given by the vector LAGS. If
%   X is multivariate, LAGGEN will concatenate the features for each lag
%   along the columns of XLAG.
%
%   Inputs:
%   x    - vector or matrix of time series data (time by features)
%   lags - vector of integer time lags (samples)
%
%   Outputs:
%   xLag - matrix of lagged time series data (time by lags*feats)
%
%   See README for examples of use.
%
%   See also MTRFTRAIN MTRFPREDICT MTRFCROSSVAL MTRFMULTICROSSVAL.

%   Author: Michael Crosse
%   Lalor Lab, Trinity College Dublin, IRELAND
%   Email: edmundlalor@gmail.com
%   Website: https://urldefense.proofpoint.com/v2/url?u=http-3A__lalorlab.net_&d=DwIBAg&c=sJ6xIWYx-zLMB3EPkvcnVg&r=21QGlXWd7N4efXKkqlAScw&m=usXSt-cK0bOTu6tpqP2-YAWHiNpXYkOn3Mes4SuKDPE&s=JAcL4ruhWhkKz4dV8K6HTfMBRFYpQquNeG5KTx8Am9U&e= 
%   April 2014; Last revision: 18 August 2015

xLag = zeros(size(x,1),size(x,2)*length(lags));

i = 1;
for j = 1:length(lags)
    if lags(j) < 0
        xLag(1:end+lags(j),i:i+size(x,2)-1) = x(-lags(j)+1:end,:);
    elseif lags(j) > 0
        xLag(lags(j)+1:end,i:i+size(x,2)-1) = x(1:end-lags(j),:);
    else
        xLag(:,i:i+size(x,2)-1) = x;
    end
    i = i+size(x,2);
end

end