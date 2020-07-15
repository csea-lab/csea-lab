function [B] = swirl(filemat); 

for index = 1:size(filemat,1); 
    
    A=imread(deblank(filemat(index,:)));

    B=uint8(zeros(size(A)));
 %   figure,imshow(A);
   
    
    %Mid point of the image
    midx=ceil((size(A,1)+1)/2);
    midy=ceil((size(A,2)+1)/2);

    K=100;

    x2=zeros([size(A,1) size(A,2)]);
    y2=zeros([size(A,1) size(A,2)]);

   for x = 1:2 % loop pver swirls (i.e. swirl twice)
    
    for i=1:size(A,1)
        x=i-midx-K;
        for j=1:size(A,2)
    %Cartesian to Polar co-ordinates
    [theta1,rho1]=cart2pol(x,j-midy+K/2);
    
    phi=theta1+(rho1/K.*.8);
    %Polar to Cartesian co-ordinates
    [l,m]=pol2cart(phi,rho1);

    
    x2(i,j)=ceil(l)+midx;

    y2(i,j)=ceil(m)+midy;

    
        end
    end
    
   %The result may produce value lesser than 1 or greater than the image size.


    x2=max(x2,1);
    x2=min(x2,size(A,1));


    y2=max(y2,1);
    y2=min(y2,size(A,2));

    for i=1:size(A,1)

        for j=1:size(A,2)

            B(i,j,:)=A(x2(i,j),y2(i,j),:);

        end
    end
 
    %flip all layers of B
     
   B2 = B; 
   B2(:,:,1) = fliplr(B2(:,:,1)); 
   B2(:,:,2) = fliplr(B2(:,:,2)); 
   B2(:,:,3) = fliplr(B2(:,:,3)); 
   
    
  A = B2; 
   end
    
    
figure (3), imshow(B); pause (1) 

imwrite(B, [deblank(filemat(index,:)) '.swirl.jpg'], 'jpg')

end

