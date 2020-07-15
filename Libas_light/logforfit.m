function [ yhat ] = logforfit( beta, x )
%this is for fitting a simple log function with an intercept

       b1 = beta(1);
       b2 = beta(2);
       yhat = b1 + b2.*log(x)';
       
end

