function[] = topomap(datavec); 

% uses eeglab function eeg_topoplot to quickly (and dirtily) map one vector as a
% topography, assumes hydrocel eeg systems

if length(datavec) == 129; 
    
   load ('locsEEGLAB129HCL.mat')
   
   eeg_topoplot( datavec , locsEEGLAB129HCL), colorbar
   
elseif length(datavec) == 257; 
    
     load ('locsEEGLAB257HCL.mat')
     
      eeg_topoplot( datavec , locsEEGLAB257HCL), colorbar
     
else
    
    error('datavec size unknown')
    
end

    
