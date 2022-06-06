function [BPMvec]  = IBI2HRchange_halfsec(IBIvec, NBsecs); 

secbins = [0:0.5:NBsecs]; 

Rwavestamps = cumsum(IBIvec); 
   
BPMvec = 60./interp1(Rwavestamps, IBIvec, secbins, 'linear', 'extrap'); 