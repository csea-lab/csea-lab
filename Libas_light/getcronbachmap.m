%getcronbachmap
function[alphamap, tempmat] = getcronbachmap(filemat,n_electrodes,n_items)
tempmat = [];
subject = 1; 
item = 1

 for electrode = 1 : n_electrodes; 
     
    for fileindex = 1 : size (filemat,1)
        
        mat = ReadAvgFile(deblank(filemat(fileindex,:))); 
        
        tempmat(subject,item) = mat(electrode);
        
        item = item+1; 
        
        if item == n_items+1, subject = subject+1, item = 1, end
        
    end
    
    subject = 1; 
    
    
    
    alphamap(electrode) = cronbach(tempmat)
    
    %pause
    
    %tempmat = []; 
    
 end
 