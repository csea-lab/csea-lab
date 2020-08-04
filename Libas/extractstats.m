
function [outmat] = extractstats(filemat, Nconditions, electrodes, samplepoints, bslvec)
 
 outmat = []; 
 filemat_test = []; 
 
for condinum = 1: Nconditions
    
   filemat_con = filemat(condinum:Nconditions:size(filemat,1),:)
    
    for subj = 1:size(filemat_con,1)
        
        a = ReadAvgFile(deblank(filemat_con(subj,:))); 
       
        if ~isempty(bslvec)
        a = bslcorr(a, bslvec); 
        end
        
        outvec(subj) = mean(mean(a(electrodes, samplepoints))); 
              
    end
    
   outmat = [outmat outvec']; 
   filemat_test = [filemat_test filemat_con] 

end

fclose('all')