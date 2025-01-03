contrast = 90/100; 
spatfreq = 0.10; 
tiltangle = 45;
gray = 10;
inc = 200; 
colormap('gray')

[x,y] = meshgrid(-100:100, -100:100);
gabor = (exp(-((x/50).^2)-((y/50).^2)) .* sin(cos(tiltangle*pi/180)*(2*pi*spatfreq)*x + sin(tiltangle*pi/180)*(2*pi*spatfreq)*y));
stimulus = gray+inc*(contrast*gabor);  

image(stimulus)