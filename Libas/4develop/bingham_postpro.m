function [ERP_happy, ERP_angry, ERP_sad, stats_amp, stats_SNR] =  bingham_postpro (datapath, conditionflag)

% this is a function that runs second in the binghamton pipeline. it has as
% input the preprocessed trial-by-trial EEG, and it produces spectra and
% output for stats. inputs: path to the data; conditionflag.  conditionflag
% 1 means that the Face is shown at 15 hz, 2 means the Gabor is shown at 15 hz. 

load(datapath)     

% happy
ERP_happy = mean(EEG_happy.data, 3); 
[amphappy, phase, freqs, fftcomp] = freqtag_FFT(ERP_happy(:, 601:5600), 1000); 
happy12HzO1OzO2= amphappy(15:17, 61)';
happy15HzO1OzO2= amphappy(15:17, 76)';

[SNRtemp, ~] = freqtag_simpleSNR(amphappy, [55:59 63:67 69:74 78:82]);
SNRhappy12HzO1OzO2 = SNRtemp(15:17, 61)';
SNRhappy15HzO1OzO2 = SNRtemp(15:17, 76)';


% angry
ERP_angry = mean(EEG_angry.data, 3); 
[ampangry, phase, freqs, fftcomp] = freqtag_FFT(ERP_angry(:, 601:5600), 1000); 
angry12HzO1OzO2= ampangry(15:17, 61)';
angry15HzO1OzO2= ampangry(15:17, 76)';

[SNRtemp, ~] = freqtag_simpleSNR(ampangry, [55:59 63:67 69:74 78:82]);
SNRangry12HzO1OzO2 = SNRtemp(15:17, 61)';
SNRangry15HzO1OzO2 = SNRtemp(15:17, 76)';

% sad
ERP_sad = mean(EEG_sad.data, 3); 
[ampsad, phase, freqs, fftcomp] = freqtag_FFT(ERP_sad(:, 601:5600), 1000); 
sad12HzO1OzO2= ampsad(15:17, 61)';
sad15HzO1OzO2= ampsad(15:17, 76)';

[SNRtemp, ~] = freqtag_simpleSNR(ampsad, [55:59 63:67 69:74 78:82]);
SNRsad12HzO1OzO2 = SNRtemp(15:17, 61)';
SNRsad15HzO1OzO2 = SNRtemp(15:17, 76)';

yscale = max(max([amphappy, ampangry, ampsad])); 

% make a nicer figure
figure

if conditionflag == 1
subplot(1,3,1), plot(freqs(1:160), amphappy(15:17, 1:160), 'g', 'LineWidth',2); 
xline(15, 'LineWidth', 1), xline(12, '-.', 'LineWidth', 1), axis([0 freqs(160) 0 yscale]), title('happy'), ylabel('voltage')
subplot(1,3,2), plot(freqs(1:160), ampangry(15:17, 1:160), 'r', 'LineWidth',2); 
xline(15, 'LineWidth', 1), xline(12, '-.', 'LineWidth', 1), axis([0 freqs(160) 0 yscale]), title('angry'), xlabel('Frequency (Hz)')
subplot(1,3,3), plot(freqs(1:160), ampsad(15:17, 1:160),'b', 'LineWidth', 2); xline(15, 'LineWidth', 1), xline(12, '-.', 'LineWidth', 1);
axis([0 freqs(160) 0 yscale]), title('sad')
xlabel(datapath(1:15))
elseif conditionflag == 2
subplot(1,3,1), plot(freqs(1:160), amphappy(15:17, 1:160), 'g', 'LineWidth',2); 
xline(15, 'LineWidth', 1), xline(12, '-.', 'LineWidth', 1), axis([0 freqs(160) 0 yscale]), title('happy'), ylabel('voltage')
subplot(1,3,2), plot(freqs(1:160), ampangry(15:17, 1:160), 'r', 'LineWidth',2); xline(15, 'LineWidth', 1), xline(12, '-.', 'LineWidth', 1);
axis([0 freqs(160) 0 yscale]), title('angry'), xlabel('Frequency (Hz)')
subplot(1,3,3), plot(freqs(1:160), ampsad(15:17, 1:160),'b', 'LineWidth',2); xline(15, 'LineWidth', 1), xline(12, '-.', 'LineWidth', 1);
axis([0 freqs(160) 0 yscale]), title('sad')
xlabel(datapath(1:15))    
end        

save([datapath(1:end-4) '.ERPs.mat'], 'ERP_happy', 'ERP_angry', 'ERP_sad', '-mat')

stats_amp = [happy12HzO1OzO2 happy15HzO1OzO2 angry12HzO1OzO2 angry15HzO1OzO2 sad12HzO1OzO2 sad15HzO1OzO2]
stats_SNR = [SNRhappy12HzO1OzO2 SNRhappy15HzO1OzO2 SNRangry12HzO1OzO2 SNRangry15HzO1OzO2 SNRsad12HzO1OzO2 SNRsad15HzO1OzO2]

csvwrite([datapath(1:end-4) '.amp.csv'], stats_amp)
csvwrite([datapath(1:end-4) '.snr.csv'], stats_SNR)