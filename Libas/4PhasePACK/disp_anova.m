function [sig, F, direction] = disp_anova( varargin )
%
%[sig, F] = disp_anova( data1, data2, ... )  
%
% DISP_ANOVA performs an analysis of dispersion on two or more angular
% distributions. If the inputs are matrices it works across the
% columns. This function returns a significance vector, F vector, and
% a direction vector. The direction vector is zero for comparisons of
% three or more distributions.
%
% Taken from Fisher (1993), pg. 131.

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

if nargin < 2 
  help disp_anova
  return
end

% if a single row is passed, transpose it
for i = 1:nargin
  if size(varargin{i}, 1) == 1
    varargin{i} = varargin{i}(:);
  end
end

% check to see that dimensions are the same
for i = 1:(nargin-1)
  if size(varargin{i}, 2) ~= size(varargin{i+1}, 2)
    error('DISP_ANOVA: incoming matrices must have the same number of columns.');
  end
end

% calculate 'n' for each distribution
n = [];
sig = []; F = []; direction = [];
for i=1:nargin
  n(i) = size(varargin{i}, 1);
end
N = sum(n);

% work across each column of data
for col = 1:size(varargin{1}, 2)
  mu = []; rbar = []; d = []; 
  data = cell(0,0);
  for i=1:nargin
    data{i} = varargin{i}(:, col);
    [mu(i), rbar(i)] = circmean( data{i} );
    d(i) = sum( abs(sin( data{i} - mu(i) )) / n(i) );
  end
  
  numsum = 0;
  denomsum = 0;
  
  D = sum( n .* d / N );
  
  for i= 1:nargin
    numsum = numsum + (n(i) * (d(i) - D)^2);
    denomsum = denomsum + sum((abs(sin( data{i} - mu(i) )) - d(i)).^2);
  end
  
  num = (N - nargin) * numsum;
  denom = (nargin - 1) * denomsum;
  
  F(col) = num/denom;
  p = 1 - fcdf(F(col), nargin-1, N-nargin);
  p = 2 * min(p, 1-p);
  sig(col) = p;
  if nargin ~= 2
    % if there are more than two distributions, a direction is not possible
    direction(col) = 0;
  elseif rbar(2) < rbar(1)
    % first distribution variance less than second distribution variance
    direction(col) = 1;
  else
    % second distribution variance less than first distribution variance
    direction(col) = -1;
  end
end

if nargout < 3
  clear direction;
end
if nargout < 2
  clear F;
end
