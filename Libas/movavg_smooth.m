% movgavg_smooth.m
function [outvec] = movavg_smooth(invec, tconstant); 

% each value oy outvec  is a weighted mean of the corresponding invec 
% values and its tconstant nearest neighbors in each direction.

for index = 1:tconstant
    
    outvec(index) = 0.75.* mean(invec(1:tconstant)) + 0.25.* invec(index); 
    
end


for index = tconstant+1 : length(invec)-tconstant
    
    outvec(index) = mean(invec(index-tconstant:index+tconstant));

end


for index = length(invec)-tconstant + 1 : length(invec)
    
    outvec(index) = 0.75.* mean(invec(length(invec)-tconstant + 1 : length(invec))) + 0.25.* invec(index); 
    
end

    
    
    
    