%getbrightness
% calcualtes brightness from jpgs. pix_area_v and *_h are vectors
% denoting the pixels included
% pixels selected, (i.e. [200:300, 200:300])
function[brightnessvec] = getbrightness(jpgfilemat,pix_area_v, pix_area_h); 



if nargin < 2, pix_area_v = []; pix_area_h = [];end

for index = 1:size(jpgfilemat,1)
    
    imagmat = imread(deblank(jpgfilemat(index,:)), 'jpg');
    
    if ~isempty(pix_area_v)
        
        brightnessvec(index) = mean(mean(mean(imagmat(pix_area_v, pix_area_h, :)))) 
        
        image(imagmat(pix_area_v, pix_area_h, :)), title(deblank(jpgfilemat(index,:))), pause(1)
        
    else

        brightnessvec(index) = mean(mean(mean(imagmat)));
        
        image(imagmat(:, :, :)), title(deblank(jpgfilemat(index,:))), pause(1)
        
    end
end