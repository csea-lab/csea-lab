function [outmat_upper, outmat_lower] = extracttags(filemat, tagginggroup); 



for index = 1:size(filemat,1)
    
    data = readavgfile(deblank(filemat(index,:))); 
    
    if tagginggroup ==1; 
        
        outmat_upper(index,:) = data(:, 45); 
        outmat_lower(index,:) = data(:, 34); 
        
    elseif tagginggroup ==2;
        
        outmat_upper(index,:) = data(:, 34); 
        outmat_lower(index,:) = data(:, 45); 
    end
        
    
    
    
end