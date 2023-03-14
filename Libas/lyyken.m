function [DataOut] = lyyken(DataIn)
%  does a Lykken range correction for the input matrix or row vector


DataOut = zeros(size(DataIn)); 

if size(DataIn, 2) > 1 % if it is a matrix or row vector; 
	
    for SubInd = 1 : size(DataIn, 1)	
         DataOut(SubInd,:) = (DataIn(SubInd,:) - nanmin(DataIn(SubInd,:))) ./ ( nanmax(DataIn(SubInd,:)) -  nanmin(DataIn(SubInd,:)));
    end
    
elseif size(DataIn, 2) == 1 % if it is a column vector
    
        DataOut = (DataIn-nanmin(DataIn))./( nanmax(DataIn) -  nanmin(DataIn));
end


