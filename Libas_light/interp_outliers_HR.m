%interp_outliers
% interpolates outlier in a vector
function [outvec] = interp_outliers_HR(invec)


    
        indexvec_out = find(invec > mean(invec) + 1.8.*std(invec) | invec < mean(invec) - 1.8.*std(invec)); 
        
        indexvec_good = find(invec < mean(invec) + 1.8.*std(invec) | invec > mean(invec) - 1.8.*std(invec));
        
        length(indexvec_out)
      
           
            
                invec(indexvec_out) =  median(invec(indexvec_good));
                

        

outvec = invec; 