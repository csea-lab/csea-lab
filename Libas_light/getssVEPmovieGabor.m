function [movmat] = getssVEPmovieGabor

    [x,y] = meshgrid(-100:100, -100:100);
    
    m1 = (exp(-((x/50).^2)-((y/50).^2)) .* sin(cos(-10*pi/180)*(2*pi*0.03)*x + sin(-10*pi/180)*(2*pi*0.03)*y));
    m2 = m1.*-1; 
    
    m3 = (exp(-((x/50).^2)-((y/50).^2)) .* sin(cos(40*pi/180)*(2*pi*0.03)*x + sin(40*pi/180)*(2*pi*0.03)*y));
    m4 = m3.*-1;
    
    filler = zeros(size(m1)); 

    colormap('gray');
    
    img1 = [filler m1 filler ;filler m4 filler];
    img2 = [filler m2 filler ;filler m3 filler ];
 
    

for j = 1 :2: 120

    
imagesc(img1), axis('off')
pause(2)
movmat(j) = getframe;
imagesc(img2), axis('off')
pause(2)
movmat(j+1) = getframe;
pause(2)


end