function [convec4EEG] = getcon_gainface2(filepath);



fid = fopen(filepath);

count = 1;
a = 1
	
 while a > 0
	
     a = fgetl(fid)
     
     if a < 0, break, return, end
 	index1 = findstr(a, 'e+000');
 	
    consymbols = deblank(a(index1(1)+6:index1(1)+8))
    consymbols(1)
    
    % FOR NOW JUST DO FACES VERSUS SCENES
        
    if consymbols(1) == 'A' || consymbols(1) == 'B'
         
         convec4EEG(count) = 1; 
    
    elseif consymbols(1) == '1'
        
         convec4EEG(count) = 2;
    else
        
        convec4EEG(count) = 3;
         
    end
        
               
    count = count+1;           
 
 end
    
 convec4EEG = convec4EEG'; 
 blockvec = [20.* ones(72,1); 10.* ones(72,1);20.* ones(72,1);10.* ones(72,1)]; 
 
 convec4EEG  = convec4EEG+blockvec; 

fclose('all')





