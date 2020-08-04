function [vidObj] = getmovie2019(filemat, framerate, outname)

vidObj = VideoWriter(outname, 'Motion JPEG AVI');
vidObj.FrameRate = framerate;
vidObj.Quality = 90;


open(vidObj);

 picmat = imread(deblank(filemat(1,:))); 
 imshow(picmat)
 
 axis tight manual
 set(gca,'nextplot','replacechildren');

for x = 1:size(filemat,1)

    picmat = imread(deblank(filemat(x,:))); 
    imshow(picmat);
    currFrame = getframe(gcf);
   
    writeVideo(vidObj,currFrame); 
    pause, 


end