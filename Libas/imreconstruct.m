function varargout = imreconstruct(varargin)
%IMRECONSTRUCT Perform morphological reconstruction.
%   IM = IMRECONSTRUCT(MARKER,MASK) performs morphological reconstruction
%   of the image MARKER under the image MASK.  MARKER and MASK can be two
%   intensity images or two binary images with the same size; IM is an
%   intensity or binary image, respectively.  MARKER must be the same size
%   as MASK, and its elements must be less than or equal to the
%   corresponding elements of MASK.
%
%   By default, IMRECONSTRUCT uses 8-connected neighborhoods for 2-D
%   images and 26-connected neighborhoods for 3-D images.  For higher
%   dimensions, IMRECONSTRUCT uses CONNDEF(NDIMS(I),'maximal').  
%
%   IM = IMRECONSTRUCT(MARKER,MASK,CONN) performs morphological
%   reconstruction with the specificied connectivity.  CONN may have the
%   following scalar values:  
%
%       4     two-dimensional four-connected neighborhood
%       8     two-dimensional eight-connected neighborhood
%       6     three-dimensional six-connected neighborhood
%       18    three-dimensional 18-connected neighborhood
%       26    three-dimensional 26-connected neighborhood
%
%   Connectivity may be defined in a more general way for any dimension by
%   using for CONN a 3-by-3-by- ... -by-3 matrix of 0s and 1s.  The 1-valued
%   elements define neighborhood locations relative to the center element of
%   CONN.  CONN must be symmetric about its center element.
%
%   Morphological reconstruction is the algorithmic basis for several
%   other Image Processing Toolbox functions, including IMCLEARBORDER,
%   IMEXTENDEDMAX, IMEXTENDEDMIN, IMFILL, IMHMAX, IMHMIN, and
%   IMIMPOSEMIN.
%
%   Class support
%   -------------
%   MARKER and MASK must be nonsparse numeric or logical arrays 
%   with the same class and any dimension.  IM is of the same class 
%   as MARKER and MASK.
%
%   See also IMCLEARBORDER, IMEXTENDEDMAX, IMEXTENDEDMIN, IMFILL, IMHMAX, 
%            IMHMIN, IMIMPOSEMIN.

%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2002/03/28 17:50:53 $

%#mex

error(sprintf('Missing MEX-file: %s', mfilename));

	