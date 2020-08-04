function [convec4EEG] = getcon_gainfaceemo(filepath);



fid = fopen(filepath);

count = 1;
a = 1
	
 while a > 0
	
     a = fgetl(fid)
     
     if a < 0, break, return, end
 	index1 = findstr(a, 'e+000');
 	
    consymbols = deblank(a(index1(1)+6:index1(1)+10))
    consymbols(1);
    
    % FOR NOW JUST DO FACES VERSUS SCENES
        
    if consymbols(5) == 'A' 
        convec4EEG(count) = 12;  
    
    elseif consymbols(5) == 'N'
        convec4EEG(count) = 11;
         
    
    elseif str2num(consymbols(2)) > 0
        
         convec4EEG(count) = str2num(consymbols(2));  
    
    end
    
    count = count+1;  
       
 
 end
    
 convec4EEG = convec4EEG'; size(convec4EEG), pause
 blockvec = [100.* ones(72,1); 200.* ones(72,1);100.* ones(72,1);200.* ones(72,1)]; 
 
 convec4EEG  = convec4EEG+blockvec; 

fclose('all')





