function [convec4EEG] = getcon_gainfaceRec(filepath);

convec4EEG =[]; 

fid = fopen(filepath);

count = 1;
a = 1
	
 while a > 0
	
     a = fgetl(fid)
     
     if a < 0, break, return, end
 	index1 = findstr(a, ' ')
    
    a(index1(2)+1:end)
    
    % faces: 
    if a(index1(2)+1) == 'A'
        convec4EEG(count) = 11; 
    elseif a(index1(2)+1) == 'F'
        convec4EEG(count) = 12; 
    elseif a(index1(2)+4) == '.'
        convec4EEG(count) = 1;
    elseif a(index1(2)+4:index1(2)+5) == '4.'
        convec4EEG(count) = 2;
    end
        
 	
    
               
    count = count+1;           
 
 end
    
 convec4EEG = convec4EEG'; 
 
 


fclose('all')





