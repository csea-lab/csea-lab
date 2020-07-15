function [ outmat ] = strucmartin2singtrial( strucmatIn, plotflag)

outmat = []; 
%   Detailed explanation goes here

names = fieldnames(strucmatIn); 

temp = strucmatIn; 

for con = 1:length(names) 
    
    actmat = eval(['strucmatIn. ' names{con}]); 
    
    ffttrialmat = []; 
     
    for trial = 1:size(actmat, 3); 
        
         [dummy, fftamp] = stead2singtrialsMat(deblank(actmat(:, :, trial)), plotflag, 50:150, 150:1400, 14.1667, 250, 850);
         
          ffttrialmat = [ffttrialmat fftamp]; 
                 
    end
    
    eval(['outmat. ' names{con} ' = ffttrialmat']);
    
end




