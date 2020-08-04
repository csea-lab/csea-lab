% calculates Meanpotentials from ATG.ar SCADS files, keeping all electrodes

function [outmat] = scads2stats(filemat, timevec_SP, bslvec_SP, elcsitevec);

for fileindex = 1: size(filemat,1); 
    
    data = ReadAvgFile(filemat(fileindex,:)); 
    
    data = bslcorr(data, bslvec_SP); 
    
    if fileindex == 1
        
        outmat = (mean(data(elcsitevec,timevec_SP), 2))'; 
       
    else
        
        outmat = [outmat; (mean(data(elcsitevec,timevec_SP),2))']; 
        
    end
    
end