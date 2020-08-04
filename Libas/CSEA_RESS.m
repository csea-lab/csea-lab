%CSEA_RESS
clear

SampRate  = 1000;

elcs = 1:2:257; % electrodes to include

Targetfreq = 8.57; 

timewin = 1241:3600; 

load('subj143_20191126_114845.fl30h2.E1.appg.mat'); 

% filter 3d
signal3d = filterFGx(outmat,1000,8.57,1);

referenceUP3d = filterFGx(outmat,1000,10.57,1);

referenceLO3d = filterFGx(outmat,1000,6.57,1);

 % reshape, time, and baseline
     signal = reshape(signal3d(:, timewin, :), 257, []); 
     signal = bsxfun(@minus,signal,mean(signal,2));
     
    referenceUP = reshape(referenceUP3d(:, timewin, :), 257, []); 
    referenceUP = bsxfun(@minus,referenceUP,mean(referenceUP,2));
    
    referenceLO = reshape(referenceLO3d(:, timewin, :), 257, []); 
    referenceLO = bsxfun(@minus,referenceLO,mean(referenceLO,2));
     
    
     % covariance   
    Sigcov = (signal * signal');
    RefcovUP = (referenceUP * referenceUP');
    RefcovLO = (referenceLO * referenceLO');
    
    [W,L]=eig(Sigcov(elcs, elcs), (RefcovUP(elcs, elcs)+RefcovLO(elcs, elcs))./2);
   % [W,L]=eig(Sigcov(elcs, elcs), RefcovUP(elcs, elcs));
    
    
    [~,comp2plot] = max(diag(L)); % find maximum component
    
    
% reconstruct RESS component time series
for trial = 1:size(outmat,3)
 RESS_time(:, :, trial) = W(:,comp2plot)'*squeeze(outmat(elcs,:, trial));
end
 
avgmat = mean(outmat,3);  

RESS_avg = W(:,comp2plot)'*squeeze(avgmat(elcs,:));

subplot(3,1,1), plot(squeeze(mean(RESS_time, 3)))
 
[pow, freq] = FFT_spectrum3D(RESS_time, timewin, 1000);

subplot(3,1,2), plot(freq(1:70), pow(1, 1:70))

[pow, pha, freq] = FFT_spectrum(RESS_avg(timewin), 1000);

subplot(3,1,3), plot(freq(1:70), pow(1, 1:70))





    
    
