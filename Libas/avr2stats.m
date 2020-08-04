% calculates Meanpotentials from ATG.ar SCADS files, keeping all electrodes

function [outmat] = avr2stats(filemat, timevec_SP, bslvec_SP, elcsitevec);

for fileindex = 1: size(filemat,1); 
    
    data = read_avr(filemat(fileindex,:)); 
    
    data = bslcorr(data, bslvec_SP); 
    
  if isempty(elcsitevec)
    if fileindex == 1
        
        outmat = (mean(data(:,timevec_SP), 2))'; 
       
    else
        
        outmat = [outmat; (mean(data(:,timevec_SP),2))']; 
        
    end 
  else   
        
    if fileindex == 1
        
        outmat = mean(mean(data(elcsitevec,timevec_SP), 2))'; 
       
    else
        
        outmat = [outmat; mean(mean(data(elcsitevec,timevec_SP),2))]; 
        
    end
  end
    
end
