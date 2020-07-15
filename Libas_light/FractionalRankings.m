function y = FractionalRankings(x)
%
%   Calculate the FRACTIONAL RANKINGS of vector x (in ascending order)
%   The Fractional Ranking y is such that sum(y) is equal to sum([1:length(x)])
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
%   y = FractionalRankings(x);
%   sortrows([x', y], 1)
%   ans =
%           13.0000    1.0000
%           22.0000    2.0000
%           32.0000    3.5000
%           32.0000    3.5000
%           46.0000    5.0000
%           57.0000    6.0000
%           69.0000    7.0000
%           73.0000    9.0000
%           73.0000    9.0000
%           73.0000    9.0000
%           87.0000   11.0000
%           95.0000   12.0000
%
%
% EXAMPLE 2:
%   x = ceil(10000 * rand(10000000, 1));
%   tic;
%   y = FractionalRankings(x);
%   toc
%   Elapsed time is 12.682000 seconds.
%
%
% EXAMPLE 3:
%   x = rand(10000000, 1);
%   tic;
%   y = FractionalRankings(x);
%   toc
%   Elapsed time is 5.772000 seconds.
%
%
%   This code has a poor performance when x is a vector with a huge Frequency Table
%   when frequencies are generally low and there exists at least one value of x with
%   frequency more than one.
%
%
%   This code is not particularly elegant nor efficient: if anyone finds out a more
%   efficient and elegant way to obtain the same result, I would greatly appreciate
%   if you could share it.
%
%
%   I acknowledge the beautiful solution for calculating Frequency Tables provided by
%   Mukhtar Ullah (mukhtar.ullah@informatik.uni-rostock.de) on the 28th of December 2004
%   http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=6631&objectType=file
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
  error('x is not a vector of numbers! The Fractional Rankings could not be calculated')
end
% Find the Frequency Distribution
[y, ind] = sort(x);
FreqTab(:, 1) = y([find(diff(y)); end]);
N1 = length(x);
N2 = length(FreqTab(:, 1));
if N1 == N2
  y(ind) = 1:N1;
  return
end
FreqTab(:, 2) = histc(y, FreqTab(:, 1));
% Find the rankings
temp = cumsum(1:N1);
temp = [0, temp(cumsum(FreqTab(:, 2)))];
temp = diff(temp);
temp = temp ./ FreqTab(:, 2)';
% Associate ranking to original data
y = (1:N1)';
k = 1;
for i = 1:N2
  if FreqTab(i, 2) > 1
    y(k:(k + FreqTab(i, 2) - 1)) = temp(i);
  end
  k = k + FreqTab(i, 2);
end
y = sortrows([y, ind], 2);
y(:, 2) = [];