function [spectrum] = bingham_calcspec(filemat)
% this function takes ERP processed files ending in ERPs.mat
% and computes a spectrum of the post-stimulus period, in the same way as
% the postpro function does.
% copy all the ERPs.mat files into new folder/have open as part of
% current folder in MATLAB
% get the filemat input by running: filemat = getfilesindir(pwd, '*ERPs.mat')
% need emegs2.8 for 'getfilesindir' commmand

spectrum = []; 

for fileindex = 1:size(filemat,1)
    
  load(deblank(filemat(fileindex,:))); 
  
  [spectrum.amphappy, phase, spectrum.freqs, fftcomp] = freqtag_FFT(ERP_happy(:, 601:5600), 1000); 
  [spectrum.ampangry, phase, freqs, fftcomp] = freqtag_FFT(ERP_angry(:, 601:5600), 1000); 
  [spectrum.ampsad, phase, freqs, fftcomp] = freqtag_FFT(ERP_sad(:, 601:5600), 1000); 
  

  save([filemat(fileindex,1:end-9) 'Spec.mat'], 'spectrum')
  
       
end



end

