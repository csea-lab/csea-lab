function [sig, F] = tcirc(a, b)
%[SIG, F] = TCIRC(A, B)
%
% Compares two distributions of complex numbers.  If length(B) = 1,
% then TCIRC compares the A distribution against the single point B
% and returns a p-value for each column in A; If length(B) > 1, then
% TCIRC returns the p-value representing the significance of the
% difference between the two column vector distributions.
%
% Taken from Victor and Mast (1991) Electroenceph. Clin. Neurophysiol.


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


DEBUG = 0;

if (size(a, 1) == 1) | isreal(a) | (size(a, 2) > 1)
  fprintf(1, 'First argument must be a column vector of complex elements.\n');
  return;
end
if (size(b, 2) > 1) | isreal(b)
  fprintf(1, 'Second argument must be a column of one or many complex elements.\n');
  return;
end

N = size(a, 1);
N2 = size(b, 1);

F = [];
sig = [];
check = [];

if (N2 == 1)
  % single distribution compared to a point
  F = (N - 1) * ((abs(mean(a) - b) .^2) / (sum(abs(a - mean(a)).^2)));

  if exist('DEBUG') & (DEBUG == 1)
    Vindiv = (1/(2*(N-1))) * sum( abs(a - mean(a)).^2 );
    Vgroup = (N/2) * ( abs(mean(a) - b).^2);
    check = (1/N) * (Vgroup/Vindiv);
  end
  
else 
  % comparing two distributions
  F = (N + N2 -2) * (abs(mean(a) - abs(mean(b))).^2) ...
      / (sum( abs(a - mean(a)).^2 ) + sum( abs(b - mean(b)).^2 ));

  if exist('DEBUG') & (DEBUG == 1)
    Vindiv = (1/(2*(N + N2 - 2))) * ( sum( abs(a - mean(a)).^2 ) + sum( abs(b - mean(b)).^2 ) );
    Vgroup = N*N2/(2*(N+N2)) * ( abs(mean(a) - abs(mean(b))).^2 );
    check = (N+N2)/(N*N2) * (Vgroup/Vindiv);
  end

end

% F table lookup
sig = 1 - fcdf(F, 2, (2*length(a)-2) );

if exist('DEBUG') & (DEBUG == 1)
  fprintf(1, 'F = %f. check = %4.3f. p = %f\n', F, check, sig);
end
