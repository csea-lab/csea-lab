function [movmat] = getssVEPmovie(filepath1, filepath2);

facepic = imread(filepath1); 
graypic = imread(filepath2); 


for j = 1 : 60


f = figure; 

colormap('gray')
if ismember(j, [1:2:60])
h(j) = imshow((facepic))

pause(1)
movmat(j) = getframe
pause(1)

else 
    
   hb(j) =  imshow((graypic))
    pause(1)
    movmat(j) = getframe
pause(1)
end

end