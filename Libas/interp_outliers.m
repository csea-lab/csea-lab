%interp_outliers
% interpolates outlier in a vector
function [outvec] = interp_outliers(invec)


M2 = 15
squarecos1 = (cos(pi/2:(pi-pi/2)/M2:pi-(pi-pi/2)/M2)).^2;
	
squarecosfunction = [squarecos1 ones(1,length(invec)-length(squarecos1).*2) fliplr(squarecos1)];
	
length(squarecosfunction)


for index = 1: length(invec); 
    
        if invec(index) > mean(invec).*2*std(invec) + 1
        invec(index) = 2* mean(invec);
        end
        
        
   
end
outvec = invec .* squarecosfunction';