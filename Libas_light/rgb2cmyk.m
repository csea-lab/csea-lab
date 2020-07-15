function c = rgb2cmyk(c)

% RGB2CMYK   Converts between RGB- and CMYK- Colors
%
% RedGreenBlue <---> CyanMangentaYellowBlack
%
% CMYK = RGB2CMYK(  RGB )
% 
%  RGB = RGB2CMYK( CMYK )
%
% RGB :  N by 3   , N Colors
% CMYK:  N by 4 
% 
%

s = size(c);
n = size(s,2);

m = s(2+(n==3));

if ~( isnumeric(c) & any( n == [ 2  3 ]) & ...
      any( m == [ 3  4 ] ) )
    error('Input must be a RGB or CMYK ColorMatrice.');
end

if isempty(c)
   return
end

u8 = strcmp(class(c),'uint8');
if u8
   c = double(c)/255;
end

sub = { ':'  ':' };
sub = sub(1:(1+(n==3)));

if m == 3
%  RGB --> CMYK

   c = 1 - c;
   k = min(c,[],n);

   c = c - k(sub{:},[1 1 1]);

   c = cat( n , c , k );

else
% CMYK --> RGB

   c = 1 - ( c(sub{:},[1 2 3]) + c(sub{:},[4 4 4]) );

end


if u8
   c = uint8(round(c*255));
end

 
   
