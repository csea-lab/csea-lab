function[h] = topomap(datamat, minmaxvec); 

% uses eeglab function eeg_topoplot to quickly (and dirtily) map one vector as a
% topography, assumes hydrocel eeg systems, or brain products 32 chan
% system for EEG-fMRI

if nargin < 2, 
    MAPLIMITS = 'absmax'
else
    MAPLIMITS = [minmaxvec(1)  minmaxvec(2)]; 
end


if size(datamat,1) == 129; 
    
   load ('locsEEGLAB129HCL.mat')
   
   for time = 1:size(datamat,2)
   
h= figure; set(h,'Position', [time*150 898 560 420]), topoplot(datamat(:,time) , locsEEGLAB129HCL, 'maplimits', MAPLIMITS), colorbar
   
   end
   
elseif size(datamat,1) == 257; 
    
     load ('locsEEGLAB257HCL.mat')
     
     for time = 1:size(datamat,2)
     
       h= figure; set(h,'Position', [time*350 898 560 420]);  topoplot( datamat(:,time) , locsEEGLAB257HCL, 'maplimits', MAPLIMITS), colorbar
      
     end
     
elseif size(datamat,1) == 16; 
    
     load ('locsOlfaxis.mat')
     
     for time = 1:size(datamat,2)
     
       h= figure; set(h,'Position', [time*150 898 560 420]);  topoplot( datamat(:,time) , locsOlfaxis, 'maplimits', MAPLIMITS), colorbar
      
     end
     
elseif size(datamat,1) == 31;
    
     load ('MRI_EEG31Locs.mat')
     
     for time = 1:size(datamat,2)
     
       h= figure; set(h,'Position', [time*150 898 560 420]);  topoplot( datamat(:,time) , MRI_EEG31Locs, 'maplimits', MAPLIMITS, 'electrodes', 'labels'), colorbar
      
      end       
else
    
    error('datavec size unknown')
    
end

    
