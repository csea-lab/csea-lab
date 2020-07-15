% readHR_bethany
function [outmat] = readHR_bethany(path)

fid = fopen(path)


outmat = []; 

line = '1'; 

while ~isempty(line)
      
dummy = fgetl(fid);
dummy = fgetl(fid);
dummy = fgetl(fid);
dummy = fgetl(fid);
    
   trialvector = []; 

    for lineindex = 1:25
        
        line = fgetl(fid)
        
        if length(line) > 40
        
            line = str2num(line);
        
            trialvector = [trialvector line]
        
        else break, return, end
       
    end
    
    if length(trialvector) > 0
    
    trialvector = trialvector(1:210), 
    
    else break, return
    
    end
    
    pause
    
    outmat = [outmat;trialvector]; 
    
end

