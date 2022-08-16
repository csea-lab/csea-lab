% filterpics
function [] = filterpics(filemat, suffix)

% % highpass + colorchannel
% for x = 1:size(filemat,1)
% a = imread(deblank(filemat(x,:)));
% a(:,:,[2 3]) = zeros(size(a,1),size(a,2),2);
% h = fspecial('log',[3 3], .2);
% I2 = imfilter(a,h);
%  imshow(I2), title('Filtered Image')
% pause(1)
% imwrite(I2,[deblank(filemat(x,:)) suffix '.jpg'], 'jpg')
% endls

% 
% % 
% % % normalize for color pic
 for fileindex = 1:size(filemat,1)
 I = imread(deblank(filemat(fileindex,:)));
 imshow(I), title('old Image')
pause(1)
% 
I = double(I);
I2 = I; 
for x = 1:3
I2(:, :, x)  =( I2(:, :, x) - mean2(I2(:, :, x) ))/std2(I2(:, :, x));
end
size(I2)

 I3 =((I2*60) + 125); 
 I3 = uint8(I3);
% 
 disp('mean brightness of this picture:  '), disp(mean2(I3))
% 
 imshow(I3), title('new Image')
 pause(1)
 
 imwrite(I3,[deblank(filemat(fileindex,:)) suffix ], 'jpg')

 end


% 
% highpass + colorchannel + threshold for both pics
% 
% for x = 1:size(filemat,1)
% a = imread(deblank(filemat(x,:)));
% h = fspecial('log',[3 3], .2);
% I2 = imfilter(a,h);
% 
% size(a), disp(filemat(x,:))
% 
% imdata_red = I2; imdata_green = I2; 
% 
% imdata_red(:,:,[2 3]) = zeros(size(I2,1),size(I2,2),2);
% imdata_green(:,:,[1 3]) = zeros(size(I2,1),size(I2,2),2);
% 
% %imshow(imdata_green), pause(1)
%  
% indexbig_green = find(imdata_green(:,:,2) > 2.6 * mean(mean(imdata_green(:,:,2)))); 
% indexbig_red = find(imdata_red(:,:,1) > 2.6 * mean(mean(imdata_red(:,:,1))));
%                        
% imdata_green_2d = zeros(size(imdata_green,1), size(imdata_green,2)); 
% imdata_red_2d= zeros(size(imdata_red,1), size(imdata_red,2));                       
%                         
%         if length(indexbig_green) < length(indexbig_red); 
% 
%             imdata_green_2d(indexbig_green) = 125; 
%             imdata_red_2d(indexbig_green) = 125; 
% 
%             imdata_green = zeros(size(imdata_green,1), size(imdata_green,2), 3); imdata_green(:,:,2) = imdata_green_2d; 
%             imdata_red = zeros(size(imdata_red,1), size(imdata_red,2), 3); imdata_red(:,:,1) = imdata_red_2d; 
% 
%         else
% 
%             imdata_green_2d(indexbig_red) = 125; 
%             imdata_red_2d(indexbig_red) = 125; 
% 
%             imdata_green = zeros(size(imdata_green,1), size(imdata_green,2), 3); imdata_green(:,:,2) = imdata_green_2d; 
%             imdata_red = zeros(size(imdata_red,1), size(imdata_red,2), 3); imdata_red(:,:,1) = imdata_red_2d; 
% 
%         end
% 
% 
% 
% imshow(imdata_green), title('Filtered Image')
% pause(1)
% imwrite(imdata_green,[deblank(filemat(x,:)) suffix '.g.jpg'], 'jpg')
% %imwrite(imdata_red,[deblank(filemat(x,:)) suffix '.r.jpg'], 'jpg')
% end

% lowpass

% % % 
% %lowpass + grayscale + normalize
% 
% for x = 1:size(filemat,1)
% a = imread(deblank(filemat(x,:)));
% I = rgb2gray(a);
% h = fspecial('average',[16 16]);
% I2 = imfilter(I,h);
% 
% I = double(I2);  
% I2 =( I - mean2(I))/(std2(I));
%  
%  I3 =((I2*25) + 120); 
%  
%  I3 = uint8(I3);
%  imshow(I3), title('Filtered Image')
% pause(1)
% 
% imwrite(I3,[deblank(filemat(x,:)) suffix '.jpg'], 'jpg')
% end
% 
%^lowpass + invert
% 
% for x = 1:size(filemat,1)
% a = imread(deblank(filemat(x,:)));
% h = fspecial('average',[36 36]);
% I2 = imfilter(a,h);
% imwrite(I2,[deblank(filemat(x,:)) suffix '.jpg'], 'jpg')
% 
% Itemp = double(I2)-127; Itemp2 = Itemp.*-1+127; 
% I2 = uint8(Itemp2); 
% imshow(I2), title('Filtered and inverted Image')
% pause(1)
% imwrite(I2,[deblank(filemat(x,:)) suffix 'inv.jpg'], 'jpg')
% end

% 
% % % %grayscale 
% % 
% for x = 1:size(filemat,1)
% a = imread(deblank(filemat(x,:)));
% 
%     if length(size(a)) > 2; 
%     I = rgb2gray(a);
%     imshow(I), title('new Image')
%     pause(1)
%     imwrite(I,[deblank(filemat(x,:)) suffix ], 'jpg')
%     end
% 
% end


% % 
% %grayscale and resize
% % % 
% for x = 1:size(filemat,1)
% [a, map] = imread(deblank(filemat(x,:)));
% I = rgb2gray(a);
% I = imresize(I,0.4);
 
% imshow(I), title('new Image')
% pause(1)
% imwrite(I,[deblank(filemat(x,:)) suffix ], 'jpg')
% end
% % % 
% % % 


% entropy
% mean2
% std2% % % % 
% warning('off')
% for x = 1:size(filemat,1)
% [a, map] = imread(deblank(filemat(x,:)));
% I = rgb2gray(a);
% 
% imshow(I), title('old Image')
% pause(1)
% 
% I = double(I);
% 
% I2 =( I - mean2(I))/std2(I);
% 
% I3 =((I2*50) + 120); 
% 
% I3 = uint8(I3);
% 
% disp('mean brightness of this picture:  '), disp(mean2(I3))
% 
% imshow(I3), title('new Image')
% pause(1)
% 
% imwrite(I3,[deblank(filemat(x,:)) suffix ], 'jpg')
% end
% warning('on')
% % 


%grayscale and normalize brightness to standard deviation

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% can also do: % just normalize - is already grayscale
% for x = 1:size(filemat,1)
% 
%     [I, map] = imread(deblank(filemat(x,:)));
%  
% imshow(I), title('old Image')
% pause(1)
%     
%     % if needs to convert to grayscale use this line: 
%     
%     I = rgb2gray(I); 
%  
%     %if needs to resize image use this line: 
%     
%    % I = imresize(I, [768, 1024]); 
%  
% 
% 
% 
% I = double(I);
% 
% I2 =( I - mean2(I))/(std2(I));
% 
% I3 =((I2*50) + 120); 
% 
% I3 = uint8(I3);
% 
% disp(['mean brightness of this picture:  ', num2str(mean2(I3))])
% disp(['contrast of this picture:  ', num2str(std2(I3))])
% disp(['range of this picture:  ', num2str(range(mat2vec(I3)))])
% 
% 
% 
% imshow(I3), title('new Image')
% pause(1)
% 
% imwrite(I3,[deblank(strtok(filemat(x,:),'.')), suffix ])
% end
% warning('on')
% 


%%%  resize ... %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% for x = 1:size(filemat,1)
%     a = imread(deblank(filemat(x,:)));
%     I = imresize(a,0.6);
%     imwrite(I,[deblank(filemat(x,:)) suffix], 'jpg')
% end

% % % % % % %%%  resize to new dimensions... %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % 
% for x = 1:size(filemat,1)
%     a = imread(deblank(filemat(x,:)));
%     I = imresize(a, [1110 800]);
%     imwrite(I,[deblank(filemat(x,:)) suffix], 'jpg')
% end
% % 
% % % % %%%  resize & cut... %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % 
% for x = 1:size(filemat,1)
%     a = imread(deblank(filemat(x,:)));
%     size(a)
%     I = a(101:900,:, :);
%     imwrite(I,[deblank(filemat(x,1:4)) suffix], 'jpg')
% end
% 
% % % %%%  change brightness by constant.. %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% for x = 1:size(filemat,1)
%     a = imread(deblank(filemat(x,:)));
%     I = a+45; 
%     imwrite(I,[deblank(filemat(x,:)) suffix], 'bmp')
% end

% %%%  cut & interpolate to old size... %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % 
%  constantshift1 = 75; constantshift2 = 100; 
% for x = 1:size(filemat,1)  
%     a = imread(deblank(filemat(x,:)));
%     index = findstr(deblank(filemat(x,:)), '.'); 
%     basename = deblank(filemat(x,1:index(1)));
%     I = a(constantshift1:size(a,1)-constantshift1,constantshift2:size(a,2)-constantshift2,:);
%     I2 = imresize(I, [768, 1024]); 
%     imwrite(I2,[basename suffix], 'jpg')
%  end

% % flip the picture by 90 degrees - assumes is 2-d matrix in UINT8
% for x = 1:size(filemat,1)
%      a = imread(deblank(filemat(x,:)));
%      I = a'; 
%      imwrite(I,[deblank(filemat(x,:)) suffix], 'jpg')
%  end





