%
% PhasePACK for MATLAB
% Version 1.2.0
% Copyright (c) 2003 Daniel S. Rizzuto, PhD
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
%
%
% This package contains MATLAB routines for analyzing angular and
% complex data sets. Several routines rely upon the MATLAB Statistics
% Toolbox to work correctly.
%
% Please refer to your MATLAB documentation on how to add PhasePACK to
% your Matlab search path. (One place to start is the 'path' command)
%
%
% Phase Analysis:
%
%  circmean   - calculate the non-weighted circular mean, mean resultant
%               length, and circular dispersion of a sample
%
%  disp_anova - test for equality of dispersion of two or more angular
%               distributions
%
%  rayleigh   - test of the null hypothesis of uniformity versus a
%               unimodal alternative
%
%  kuiper     - test of the null hypothesis of uniformity against
%               any alternative
%
%  cmean_test - compare the means of two angular distributions
%
%  circcor    - correlate a circular variable with a linear variable
%
%  crank      - calculate the circular rank of each element
%
% Complex Analysis:
%
%  tcirc      - compare two distributions of complex numbers
%
