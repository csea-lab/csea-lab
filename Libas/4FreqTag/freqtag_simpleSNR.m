function [SNRdb, SNRratio] = freqtag_simpleSNR(data, noisebins)
% This is a simple method for computing an estimate of the signal-to-noise
% ratio for a ssVEP response in the frequency domain
% data is a power spectrum in 2-D format (electrodes by frequencies)
% noisebins are the frequency bins in the spectrum NOT in Hz, but as
% relative position on the frequency axis (e.g., the 3rd and 6th frequencies 
% would be indicated as [3 6];  
% To facilitate method checks, the entire spectrum is output, with all
% frequencies expressed as ratio (or in decibels)  relative to 
% the mean power at the frequencies used to estimate the noise. 
% see the enclosed live script for usage examples.

    
    divmat = repmat(mean(data(:, noisebins), 2), 1, size(data,2)); 
    
    SNRratio  = data./divmat; 
    
    SNRdb = 10 * log10(SNRratio);
    
    
    
    
  
    



