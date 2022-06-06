function [Un, Dn] = circcor( circvar, linearvar )
% [UN, DN] = circcor( circvar, linearvar )
%
%   CIRCCOR correlates a circular variable with a linear variable 
%   and returns a U-value, which should be compared to the lookup 
%   table on pg. 231 of 'Statistical analysis of circular data.'
%   Fisher (1993).

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

if nargin == 0
  help circcor;
  return;
end

% turn into column vectors
cirvar = circvar(:);
linearvar = linearvar(:);


if length(circvar) ~= length(linearvar)
  error(' CIRCVAR and LINEARVAR must be of the same length.');
  return;
end

len = length(circvar);

r = crank( circvar );
s = ordrank( linearvar )';

a = 0;
if rem(len,2)
  a = 2 * sin(pi/len)^4 / (1 + cos(pi/len))^3;
else
  a = 1 / (1 + 5*cot(pi/len)^2 + 4*cot(pi/len)^4);
end

Tc = sum( s .* cos(r) );
Ts = sum( s .* sin(r) );

Dn = a * (Tc^2 + Ts^2);
Un = 24 * (Tc^2 + Ts^2)/(len^3 + len^2);
