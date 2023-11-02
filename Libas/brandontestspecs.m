filemat = getfilesindir(pwd, '*zGab*Spec.mat')

for index1 = 1:size(filemat,1)

    load(deblank(filemat(index1,:)))

    plot(spectrum.freqs(1:300), spectrum.amphappy(15:17, 1:300))

    pause

end

[GMspectrum] = bingham_avgsubj(filemat, 'GMtest');
%%
amphappy = GMspectrum.amphappy;
ampangry = GMspectrum.ampangry;
ampsad = GMspectrum.ampsad;
freqs = GMspectrum.freqs;

yscale = max(max([amphappy(16,:), ampangry(16,:), ampsad(16,:)]))+.2; 

%%
conditionflag = 2
if conditionflag == 1
subplot(1,3,1), plot(freqs(1:160), amphappy(15:17, 1:160), 'g', 'LineWidth',2); 
xline(15, 'k', 'Face', 'LineWidth', 1), xline(12, 'k-.', 'Gabor', 'LineWidth', 1);
axis([0 freqs(160) 0 yscale]), title('happy'), ylabel('voltage')
subplot(1,3,2), plot(freqs(1:160), ampangry(15:17, 1:160), 'r', 'LineWidth',2); 
xline(15, 'k', 'Face', 'LineWidth', 1), xline(12, 'k-.', 'Gabor', 'LineWidth', 1);
axis([0 freqs(160) 0 yscale]), title('angry'), xlabel('Frequency (Hz)')
subplot(1,3,3), plot(freqs(1:160), ampsad(15:17, 1:160),'b', 'LineWidth',2); xline(15, 'k', {'Face'}, 'LineWidth', 1), xline(12, 'k-.', {'Gabor'}, 'LineWidth', 1);
axis([0 freqs(160) 0 yscale]), title('sad')

elseif conditionflag == 2
subplot(1,3,1), plot(freqs(1:160), amphappy(15:17, 1:160), 'g', 'LineWidth',2); 
xline(15, 'k','Gabor', 'LineWidth', 1), xline(12, '-.', 'Face', 'LineWidth', 1), axis([0 freqs(160) 0 yscale]), title('happy'), ylabel('voltage')
subplot(1,3,2), plot(freqs(1:160), ampangry(15:17, 1:160), 'r', 'LineWidth',2); xline(15, 'k', 'Gabor', 'LineWidth', 1), xline(12, '-.', 'Face', 'LineWidth', 1);
axis([0 freqs(160) 0 yscale]), title('angry'), xlabel('Frequency (Hz)')
subplot(1,3,3), plot(freqs(1:160), ampsad(15:17, 1:160),'b', 'LineWidth',2); xline(15, 'k', 'Gabor', 'LineWidth', 1), xline(12, '-.', 'Face', 'LineWidth', 1);
axis([0 freqs(160) 0 yscale]), title('sad')
  
end        