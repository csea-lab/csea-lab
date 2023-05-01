function [plidiff, phasestabmat] = summary_shread(filemat)

for index1 = 1:size(filemat,1);

slidwinmatpath = filemat(index1,:);
temp = load(slidwinmatpath); 
datastruc = temp.outmat; 

plidiff(:, index1) = mean(datastruc.plidiff, 2)
phasestabmat(:, index1) = mean(datastruc.phasestabmat, 2)
fftamp(:, index1) = mean(datastruc.fftamp, 2)
trialSNR(:, index1) = mean(datastruc.trialSNR, 2)

end


figure(1) 
subplot(2,1,1), pcolor(plidiff(1:129, :)), colorbar
title('within trial phase-locking with Oz, parent (top) and infant (bottom)') 
subplot(2,1,2), pcolor(plidiff(130:end, :)), colorbar

figure(2) 
subplot(2,1,1), pcolor(phasestabmat(1:129, :)), colorbar
title('within-trial ssvep phase locking, parent (top) and infant (bottom)') 
subplot(2,1,2), pcolor(phasestabmat(130:end, :)), colorbar

figure(3) 
subplot(2,1,1), pcolor(log(fftamp(1:129, :))), colorbar
title('log ssvep power, parent (top) and infant (bottom)') 
subplot(2,1,2), pcolor(log(fftamp(130:end, :))), colorbar

figure(4) 
subplot(2,1,1), pcolor(trialSNR(1:129, :)), colorbar
title('ssvep SNR, parent (top) and infant (bottom)') 
subplot(2,1,2), pcolor(trialSNR(130:end, :)), colorbar

figure(5)
subplot(4,1,1), pcolor(plidiff(1:129, :)-plidiff(130:end, :)), colorbar
title('differences, parent minus infant')
subplot(4,1,2), pcolor(phasestabmat(1:129, :)-phasestabmat(130:end, :)), colorbar
subplot(4,1,3), pcolor(fftamp(1:129, :)-fftamp(130:end, :)), colorbar
subplot(4,1,4), pcolor(trialSNR(1:129, :)-trialSNR(130:end, :)), colorbar

