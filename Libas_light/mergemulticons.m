
function  mergemulticons(filemat, Nconditions, outname)


 filemat_test = []; 
 
for condinum = 1: Nconditions
    
   filemat_con = filemat(condinum:Nconditions:size(filemat,1),:)
   
   MergeAvgFiles(filemat_con, [outname '.at' num2str(condinum)] ,1,1,[],0,[],[],0,0)
    
end

fclose('all')