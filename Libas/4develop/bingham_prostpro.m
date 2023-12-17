function [ERP_happy, ERP_angry, ERP_sad] =  bingham_prostpro (datapath)

load(datapath)     

% happy
ERP_happy = mean(EEG_happy.data, 3); 
[amphappy, phase, freqs, fftcomp] = freqtag_FFT(ERP_happy(:, 601:5600), 1000); 
happy12HzO1OzO2= amphappy(15:17, 61)'
happy15HzO1OzO2= amphappy(15:17, 76)'

[SNRtemp, ~] = freqtag_simpleSNR(amphappy, [55:59 63:67 69:74 78:82]);
SNRhappy12HzO1OzO2 = SNRtemp(15:17, 61)'
SNRhappy15HzO1OzO2 = SNRtemp(15:17, 76)'


% angry
ERP_angry = mean(EEG_angry.data, 3); 
[ampangry, phase, freqs, fftcomp] = freqtag_FFT(ERP_angry(:, 601:5600), 1000); 
angry12HzO1OzO2= ampangry(15:17, 61)'
angry15HzO1OzO2= ampangry(15:17, 76)'

[SNRtemp, ~] = freqtag_simpleSNR(ampangry, [55:59 63:67 69:74 78:82]);
SNRangry12HzO1OzO2 = SNRtemp(15:17, 61)'
SNRangry15HzO1OzO2 = SNRtemp(15:17, 76)'

% sad
ERP_sad = mean(EEG_sad.data, 3); 
[ampsad, phase, freqs, fftcomp] = freqtag_FFT(ERP_sad(:, 601:5600), 1000); 
sad12HzO1OzO2= ampsad(15:17, 61)'
sad15HzO1OzO2= ampsad(15:17, 76)'


[SNRtemp, ~] = freqtag_simpleSNR(ampsad, [55:59 63:67 69:74 78:82]);
SNRsad12HzO1OzO2 = SNRtemp(15:17, 61)'
SNRsad15HzO1OzO2 = SNRtemp(15:17, 76)'

save([datapath(1:end-4) '.ERPs.mat'], 'ERP_happy', 'ERP_angry', 'ERP_sad', '-mat')
