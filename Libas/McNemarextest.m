function [P] = McNemarextest(v,t,alpha)
%MCNEMAREXTEST McNemar's Exact Test.
%   MCNEMAREXTEST, performs the conditional McNemar's exact test for two 
%   dependent (correlated) samples that can occur in matched-pair studies
%   with a dichotomous (yes-no) response. Dependent samples can also occur
%   when the same subject is measured at two different times. It tests the 
%   null hypothesis of marginal homogeneity. This implies that rows totals
%   are equal to the corresponding column totals. So, since the a- and the 
%   d-value on both sides of the equations cancel, then b = c. This is the
%   basis of the proposed test by McNemar (1947). The McNemar test tests the
%   null hypothesis that conditional on b + c, b has a binomial (b + c, 1/2)
%   distribution.
%
%   According to the next 2x2 table design,
%
%                   Sample 1
%                --------------
%                  Y        N
%                --------------
%             Y    a        b      r1=a+b
%   Sample 2
%             N    c        d      r2=c+d
%                --------------
%                c1=a+c   c2=b+d  n=c1+c2
%
%    (Y = yes; N = no)
%
%   The proper way to test the null hypothesis is to apply the one-sample
%   binomial test. If there is no association between b and c values, then
%   the probability is 0.5 that the sample 1 and sample 2 pair falls in the 
%   upper-right cell and 0.5 that it falls in the lower-left cell, given
%   that the pair falls off the main diagonal.
%
%   Syntax: function McNemarextest(v,t,alpha) 
%      
%   Inputs:
%         v - data vector defined by the observed frequency cells [a,b,c,d].
%         t - desired test [t = 1, one-tail; t = 2, two-tail (default)].
%     alpha - significance level (default = 0.05).
%
%   Output:
%         A table with the proportion of success for the dependent samples
%           and the P-value. 
%
%   Example: From the example on Table 10.5 given by Hollander and Wolfe (1999), in a
%            matched-pair study we are interested to testing by the McNemar's exact 
%            one-sided test the null hypothesis that the success for the dependent 
%            samples (sample 1 and sample 2) are equal. The data are given as follow.
%
%                                   Sample 1
%                            ---------------------
%                                Y            N
%                            ---------------------
%                      Y        26           15
%          Sample 2                 
%                      N         7           37
%                            ---------------------
%                                       
%            v = [26,15,7,37];
%
%   Calling on Matlab the function: 
%             McNemarextest(v,1,0.05)
%
%   Answer is:
%
%   Table for the McNemar's exact test.
%   -------------------------------------------
%         Proportion of success  
%   --------------------------------
%       Sample 1        Sample 2           P  
%   -------------------------------------------
%        0.3882          0.4824         0.0669
%   -------------------------------------------
%   For a selected one-saided test.
%   With a given significance of: 0.050
%   The alternative results not significative.
%
%  Created by A. Trujillo-Ortiz, R. Hernandez-Walls and A. Castro-Perez
%             Facultad de Ciencias Marinas
%             Universidad Autonoma de Baja California
%             Apdo. Postal 453
%             Ensenada, Baja California
%             Mexico.
%             atrujo@uabc.mx
%  Copyright (C) November 5, 2004.
%
%  $$Authors thank the valuable to-improve comments on the m-file review given
%    by I.Y., dated 2006-05-23. Modified lines are 138-143$$ 
%
%  To cite this file, this would be an appropriate format:
%  Trujillo-Ortiz, A., R. Hernandez-Walls and A. Castro-Perez. (2004).
%    McNemarextest:McNemar's Exact Probability Test. A MATLAB file. [WWW document].
%    URL http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=6297
%
%  References:
% 
%  Hollander, M. and Wolfe, D.A. (1999), Nonparametric Statistical Methods (2nd ed.).
%        NY: John Wiley & Sons. p. 468-470.
%  McNemar, Q. (1947), Note of the sampling error of the difference between 
%        correlated proportions or percentages. Psychometrika, 12:153-157.
%

if length(v) ~= 4,
    error('Vector must have four data. The a,b,c,d entry for the 2x2 table.');
    return;
end

if nargin < 3,
   alpha = 0.05;  %(default) 
elseif (length(alpha)>1),
   error('Requires a scalar alpha value.');
elseif ((alpha <= 0) | (alpha >= 1)),
   error('Requires 0 < alpha < 1.');
end

if nargin < 2, 
    t = 2;  %two-tailed test 
end

%Observed frequency cells definition
a = v(1);
b = v(2);
c = v(3);
d = v(4);

%Marginal totals calculation
r1 = a+b;
r2 = c+d;
c1 = a+c;
c2 = b+d;
n = c1+c2;

%Interested sample proportions 
P1 = c1/n;
P2 = r1/n;

%One-sample Binomial distribution procedure
p = 0.5;
m = b+c;
x = max(b,c); 

P  =0; 
for i = x:m, 
    P=P+(p.^i)*(1-p).^(m-i)*nchoosek(m,i); 
end 

%Kind hypothesis selection
if t == 1;
    P = P;
else t == 2;
    P = 2*P;
end

disp(' ')
disp('Table for the McNemar''s exact test.')
fprintf('-------------------------------------------\n');
disp('      Proportion of success  '); 
fprintf('--------------------------------\n');
disp('    Sample 1        Sample 2           P  '); 
fprintf('-------------------------------------------\n');
fprintf(' %10.4f      %10.4f       %8.4f\n',[P1,P2,P].');
fprintf('-------------------------------------------\n');
if t == 1
    disp('For a selected one-saided test.')
    fprintf('With a given significance of: %.3f\n', alpha);
    if P > alpha;
        disp('The alternative results not significative.')
    else P <= alpha;
        disp('The alternative results significative.')
    end
else t == 2;
    disp('For a selected two-saided test.')
    fprintf('With a given significance of: %.3f\n', alpha/2);
    if P > alpha/2;
        disp('The alternative results not significative.')
    else P <= alpha/2;
        disp('The alternative results significative.')
    end
end
disp(' ')

return;