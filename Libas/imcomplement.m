function im2 = imcomplement(im)
%IMCOMPLEMENT Complement image.
%   IM2 = IMCOMPLEMENT(IM) computes the complement of the image IM.  IM
%   can be a binary, intensity, or RGB image.  IM2 has the same class and
%   size as IM.
%
%   In the complement of a binary image, zeros become ones and ones
%   become zeros; black and white are reversed.  In the complement of an
%   intensity or RGB image, each pixel value is subtracted from the
%   maximum pixel value supported by the class (or 1.0 for
%   double-precision images), and the difference is used as the pixel
%   value in the output image.  In the output image, dark areas become
%   lighter and light areas become darker.
%
%   Note
%   ----
%   If IM is a double intensity or RGB image, you can use the expression
%   1-IM instead of this function.  If IM is a binary image, you can use
%   the expression ~IM instead of this function.
%
%   Example
%   -------
%       I = imread('bonemarr.tif');
%       J = imcomplement(I);
%       imshow(I), figure, imshow(J)
%
%   See also IMABSDIFF, IMADD, IMDIVIDE, IMLINCOMB, IMMULTIPLY, IMSUBTRACT. 

%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.12 $  $Date: 2002/03/15 15:27:48 $

switch class(im)
 case 'logical'
  im2 = ~im;
    
 case 'double'
  im2 = 1 - im;
  
 case 'single'
  im2 = imlincomb(-1,im,1);
  
 case 'uint8'
  im2 = imlincomb(-1,im,double(uint8(inf)));
  
 case 'uint16'
  im2 = imlincomb(-1,im,double(uint16(inf)));
  
 case 'uint32'
  im2 = imlincomb(-1,im,double(uint32(inf)));
  
 case 'int8'
  im2 = imlincomb(-1,im,double(int8(inf)));
  
 case 'int16'
  im2 = imlincomb(-1,im,double(int16(inf)));
  
 case 'int32'
  im2 = imlincomb(-1,im,double(int32(inf)));
  
 otherwise
  error('Invalid input image class.')
end

	