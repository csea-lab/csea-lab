function [ ImgOut ] = lenify(filemat)

for index = 1:size(filemat,1)
    
    picture_path = deblank(filemat(index,:)); 

a = imread(picture_path);
  
if size(a,3)==3; 
    
    imag = rgb2gray(a); 
else
    imag = a;
    
end

ret = customgauss([762 562], 200, 120, 180, -0.1, 0.8, [0 0]).*1.5;%
%ret = customgauss([768 1024], 200, 120, 180, -0.1, 0.8, [0 0]).*1.5;

ret(ret>0.5) = 0.5;

%figure(1), mesh(ret)

ImgOut = uint8((double(imag).*ret)+120); 

figure(2),imshow(ImgOut); 

imwrite(ImgOut,[deblank(picture_path) '.lena.jpg'], 'jpg')

pause
end




