function [p, V, Dp, Dn] = kuiper( data )
%
% [p, V, Dp, Dn] = kuiper( DATA )
%
% Returns the p-value and V statistic for Kuiper's test of uniformity
% against any alternative.

% Copyright (C) 2003  Daniel Rizzuto, PhD
%
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

if nargin ~= 1
  help kuiper;
  return;
end

x = sort(data(:)) / (2*pi);
N = length( x );
frac = linspace(1/N, 1, N)';

Dp = max(frac - x);
Dn = max([x(1); x(2:end) - frac(1:end-1)]);
V = Dp + Dn;
V = V  * (sqrt(N) + 0.155 + 0.24/sqrt(N));
p = probkp( V );


function p = probkp( alam )
%
% Kuiper probability function, adapted from Numerical Recipes in C
% (Press, et al, 1988). Tested against values from Appendix A.5 in
% Fisher (1993).

eps1 = 0.001;
eps2 = 1e-8;

fac = 2.0;
a2 = -2*alam^2;
p=0;
termbf=0;
for j=1:100
  term = 2 * (4.0 * j^2*alam^2 - 1) * exp(a2*j^2);
  p = p + term;
  if( (abs(term)<=eps1*termbf) | (abs(term)<=eps2*p) ) 
    return;
  end
  termbf = term;
end

warning('kuiper.m: failed to converge.\n');
p = 1;
