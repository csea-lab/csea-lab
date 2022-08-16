function [p, Yr, R] = cmean_test( varargin )
% P = CMEAN_TEST( data1, data2, ..., dataN )
%
% Nonparametric test for the equality of circular means. Returns a
% p-value for each column of data.
%
% Taken from Fisher (1993), section 5.3.4.

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

r = nargin;
verbose = 0;

if r < 2
  help cmean_test
  return;
end

p = []; Yr = []; R = [];
for col = 1:size(varargin{1}, 2)
  theta = zeros(1, r);
  rbar = zeros(1, r);
  delta = zeros(1, r);
  N = zeros(1, r);

  for i=1:r
    dat = varargin{i}(:, col);
    N(i) = size(dat, 1);
    [theta(i), rbar(i), delta(i)] = circmean( dat );
  end

  if ((max(delta) / min(delta)) <= 4)
    C = sum( N .* cos(theta) );
    S = sum( N .* sin(theta) );
    disp = sum(N .* delta) / sum(N);
    R(col) = sqrt( C^2 + S^2 );
    Yr(col) = 2 * (sum(N) - R(col)) / disp;
    if  verbose
      fprintf('%s: even dispersions: ', mfilename);
      fprintf('%.3f ', delta);
    end
  else
    C = sum( cos(theta) ./ (delta./N) );
    S = sum( sin(theta) ./ (delta./N) );
    sumsigsq = sum( N./delta );
    R(col) = sqrt( C^2 + S^2 );
    Yr(col) = 2 * (sumsigsq - R(col));
    if verbose
      fprintf('%s: uneven dispersions: ', mfilename);
      fprintf('%.3f ', delta);
    end
  end
end

p = 1 - chi2cdf(Yr, r-1);

if verbose
  fprintf('Yr = %.3f, p=%.3f.\n', Yr, p);
end
