function g = ordrank( data )
% ORDRANK provides a matrix of size(DATA) containing the ordinary ranks of
% each of the items in DATA.

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

g = zeros( size(data) );
sorted = sort( data(:) );
len = length(data(:));

for i=1:len;
  tmp = find(sorted == data(i));
  for j=1:length(tmp)
    g(i) = tmp(j);
  end
end
