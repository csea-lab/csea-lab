function [v a Ter] = ezDiffusion(Pc, VRT, MRT, s)
%EZDIFFUSION  returns the 3 paramaters of the ez Diffusion model:
% drift rate (v), boundary seperation (a), and non-decision time (Ter) 
% 3 required inputs:
% Pc, percentage correct
% VRT, variance of response time
% MRT, mean response time
% s(optional), defaults to 0.1

%   References:
%   [1] Wagenmakers, E. J., Van Der Maas, H. L., & Grasman, R. P. (2007). 
%            An EZ-diffusion model for response time and accuracy. 
%            Psychonomic bulletin & review, 14(1), 3-22.
%
%    %%%%%%%%%% written 10/14/20 M.Friedl %%%%%%%%%%  
%    %%%%%%%%%%  Last edit n/a            %%%%%%%%%%

% Default value of s 
    if nargin < 4
    s = 0.1;
    end
s2 = s^2;
% error checking; if Pc equals 0, .5, or 1, the method will not work 
% and an edge correction? is required
    if Pc==0 || Pc==0.5 || Pc==1
    error('Pc value invalid: edge correction required');
    end    
% L=qlogis(Pc) in R
L = log(Pc/(1-Pc));
x = L*(L*Pc^2 - L*Pc + Pc - .5)/VRT;
v = sign(Pc-.5)*s*x^(1/4);
a = s2*log(Pc/(1-Pc))/v;
y = -v*a/s2;
MDT = (a/(2*v)) * (1-exp(y))/(1+exp(y));
Ter = MRT - MDT;


end




