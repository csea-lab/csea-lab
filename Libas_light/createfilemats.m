
function [filemats] = createfilemats(filemat, Nconditions)
 
 
for condinum = 1: Nconditions
    
   eval(['filemats.con' num2str(condinum) ' = filemat(condinum:Nconditions:size(filemat,1),:)'])

end

