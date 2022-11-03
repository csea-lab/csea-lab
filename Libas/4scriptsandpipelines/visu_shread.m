function [] = visu_shread(slidwinmatpath)

temp = load(slidwinmatpath); 

datastruc = temp.outmat; 

figure(1) 
subplot(2,1,1), pcolor(datastruc.plidiff(1:129, :)), colorbar
title('within trial phase-locking with Oz, parent (top) and infant (bottom)') 
subplot(2,1,2), pcolor(datastruc.plidiff(130:end, :)), colorbar

figure(2) 
subplot(2,1,1), pcolor(datastruc.phasestabmat(1:129, :)), colorbar
title('within-trial ssvep phase locking, parent (top) and infant (bottom)') 
subplot(2,1,2), pcolor(datastruc.phasestabmat(130:end, :)), colorbar

figure(3) 
subplot(2,1,1), pcolor(log(datastruc.fftamp(1:129, :))), colorbar
title('log ssvep power, parent (top) and infant (bottom)') 
subplot(2,1,2), pcolor(log(datastruc.fftamp(130:end, :))), colorbar

figure(4) 
subplot(2,1,1), pcolor(datastruc.trialSNR(1:129, :)), colorbar
title('ssvep SNR, parent (top) and infant (bottom)') 
subplot(2,1,2), pcolor(datastruc.trialSNR(130:end, :)), colorbar

figure(5)
subplot(4,1,1), pcolor(datastruc.plidiff(1:129, :)-datastruc.plidiff(130:end, :)), colorbar
title('differences, parent minus infant')
subplot(4,1,2), pcolor(datastruc.phasestabmat(1:129, :)-datastruc.phasestabmat(130:end, :)), colorbar
subplot(4,1,3), pcolor(datastruc.fftamp(1:129, :)-datastruc.fftamp(130:end, :)), colorbar
subplot(4,1,4), pcolor(datastruc.trialSNR(1:129, :)-datastruc.trialSNR(130:end, :)), colorbar