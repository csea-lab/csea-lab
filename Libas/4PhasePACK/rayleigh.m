function [p, Rbar] = rayleigh(data)
% P, Rbar = RAYLEIGH( DATA )
%
% Calculates the p-value for the probability that the data are drawn
% from a uniform distribution rather than a unimodal distribution of
% unknown mean direction. Returns p and Rbar for each column of DATA.

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


n = size(data, 1);
cols = size(data, 2);

Rbar = []; p = [];
for i=1:cols
  [theta, Rbar(i)] = circmean( data(:, i) );
  Z = n*Rbar(i)^2;
  p(i) = exp(-Z) * (1 + (2*Z - Z^2) / (4*n) - (24*Z - 132*Z^2 + 76*Z^3 - 9*Z^4) / (288*n^2));
end
