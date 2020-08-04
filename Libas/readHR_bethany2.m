% readHR_bethany
function [outmat] = readHR_bethany2(path)

fid = fopen(path)

trialvector = []; 

endflag = []; 

outmat = []; 

line = '1'; 

while line ~= -1
    
    line = fgetl(fid)
    fpointer = strfind(line,'f')
    
    
    if fpointer > 1
        
        line = fgetl(fid);
        
        looppointer = 1 ;
        
        while looppointer > 0
            
            line = fgetl(fid)
            
           
        
            if isempty(strfind(line,'C'))
                
                if line == -1, break, return
                else line = str2num(line);
                end
        
                trialvector = [trialvector line]
                
            elseif strfind(line,'C') > 1
         
                trialvector = trialvector(1:245)
      
                looppointer = -1
                if isempty(outmat), outmat = [trialvector]
                else outmat = [outmat;trialvector]
                end
                trialvector = []; 
                fpointer = 0
                
                
            end
         
        end
        
         
      
    end
   
  
end

trialvector = trialvector(1:245)
outmat = [outmat;trialvector]  