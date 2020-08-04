function [BPMvec]  = IBI2HRchange_halfsec(Rwavestamps, NBsecs); 

if Rwavestamps(1) <= 0; 
    Rwavestamps(1) = 0.01;
end


IBIvec = diff(Rwavestamps);

secbins = [0:0.5:NBsecs]; 
   
BPMvec = 60./interp1(Rwavestamps(1:end-1),[IBIvec], secbins, 'linear', 'extrap'); 