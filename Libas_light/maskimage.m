function [outpic] = maskimage(filemat, mask, suffix)

for imageindex = 1:size(filemat,1);
test = imread(deblank(filemat(imageindex,:)));

outpic = test.*uint8(mask); 
outpic(mask==0) = 125; 

colormap('gray'); imshow(outpic)
pause

imwrite(outpic,[deblank(filemat(imageindex,:)) suffix ], 'jpg')

end