function y = DenseRankings(x)
%
%   Calculate the DENSE RANKINGS of vector x (in ascending order)
%
%   For details regarding ranking methodologies: http://en.wikipedia.org/wiki/Ranking
%
%
% INPUT
%   The user supplies the data vector x.
%
%
% EXAMPLE 1:
%   x = [32 73 46 32 95 73 87 73 22 69 13 57];
%   y = DenseRankings(x);
%   sortrows([x', y], 1)
%   ans =
%            13     1
%            22     2
%            32     3
%            32     3
%            46     4
%            57     5
%            69     6
%            73     7
%            73     7
%            73     7
%            87     8
%            95     9
%
%
% EXAMPLE 2:
%   x = ceil(10000 * rand(10000000, 1));
%   tic;
%   y = DenseRankings(x);
%   toc
%   Elapsed time is 6.950000 seconds.
%
%
% EXAMPLE 3:
%   x = rand(10000000, 1);
%   tic;
%   y = DenseRankings(x);
%   toc
%   Elapsed time is 7.082000 seconds.
%
%
%   This code seems to show very high performances. I have found it here:
%   http://www.mathworks.com/matlabcentral/newsreader/viewthread/163003
%   The solution was proposed by us@neurol.unizh.ch on the 12th of February 2008.
%
%
%   If anyone finds out a more efficient and elegant way to obtain the same result,
%   I would greatly appreciate if you could share it.
%
%
%   Author: Francesco Pozzi
%   E-Mail: francesco.pozzi@anu.edu.au
%   Date: 08-04-2008
% 
% 
% 

% Prepare data
ctrl = isvector(x) & isnumeric(x);
if ctrl
  x = x(:);
  x = x(~isnan(x) & ~isinf(x));
else
  error('x is not a vector of numbers! The Dense Rankings could not be calculated')
end
[y, y, y] = unique(x);