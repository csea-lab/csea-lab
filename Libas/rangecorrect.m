function [DataOut] = rangecorrect(DataIn)
%  does a Lykken range correction for the input matrix or row vector


DataOut = zeros(size(DataIn)); 

if size(DataIn, 2) > 1 % if it is a matrix or row vector; 
	
    for SubInd = 1 : size(DataIn, 1)	
         DataOut(SubInd,:) = (DataIn(SubInd,:) - nanmean(DataIn(SubInd,:))) ./ ( nanmax(DataIn(SubInd,:)) -  nanmin(DataIn(SubInd,:)));
    end
    
elseif size(DataIn, 2) == 1 % if it is a column vector
    
        DataOut = (DataIn-nanmean(DataIn))./( nanmax(DataIn) -  nanmin(DataIn));
end



%rangecorr
% % transforms a vector of numbers into range-corrected values using lykken
% % range correction: (x-min)/(max-min) 
% function [out] = rangecorrect(invec) 
% 
% out = (invec -mean(invec)) ./ (max(invec) - min(invec)); 
% >>>>>>> a737f06392f84ed4a1470a6e0acf956f65ba6984
