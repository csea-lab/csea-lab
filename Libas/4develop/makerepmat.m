function [repmat] = makerepmat(filemat, Nsubjects, Nconditions)

% makes  4-D array for contrast_rep 
% if each person/condition file has 2-D 
% (elec by time or elec by freq)
% if it is only elecs, will make a 3-D array


for con = 1:Nconditions
    
   for sub = 1:Nsubjects
       
      index = con + (sub*Nconditions) - Nconditions;
    
      a = ReadAvgFile(filemat(index,:)); 
      
      if ndims(a) == 2
      
            repmat(:, :, sub, con) = a; 
      
      elseif ndims(a) == 1
          
           repmat(:, sub, con) = a; 
      end
      
       
   end
   
end
