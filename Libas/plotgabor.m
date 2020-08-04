function [gaborout, test] = plotgabor(orientation, spatialfreq)

pixelsize = 200

[x,y] = meshgrid(-pixelsize:pixelsize, -pixelsize:pixelsize);

test =  exp(-((x/60).^2)-((y/60).^2)) ; test(test<0.0001) = 0; 

m2 = (test .* sin(cos(-orientation*pi/180)*(2*pi*spatialfreq)*x + sin(-orientation*pi/180)*(2*pi*spatialfreq)*y));

gaborout = m2./3 + 0.5; 


colormap('gray')
imshow(gaborout, [0 1])