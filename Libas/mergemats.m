function [mergedmat] = mergemats(matfilemat, dimension, outname);

for index = 1:size(matfilemat,1); 
    
    strucmat = load(deblank(matfilemat(index,:))); 
    
    if index == 1; 
        
        mergedmat = strucmat.outmat; 
        
    else
        
        mergedmat = cat(dimension, mergedmat, strucmat.outmat); 
        
    end
    
end


eval(['save ' outname ' mergedmat -mat']); 

fclose('all');

end