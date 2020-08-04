eeglab
plot(EEG.data(1,:))
plot(EEG.data(21,:))
plot(EEG.data(20,:))
plot(EEG.data(19,:))
EEG
EEG.chanlocs
EEG.chanlocs.labels
plot(EEG.data(18,:))
plot(EEG.data(17,:))
plot(EEG.data(16,:))
for chan = 1:21
plot(EEG.data(chan,:)), pause, end
for chan = 1:21
plot(EEG.data(chan,:)), title(num2str(chan)); pause, end
plot(EEG.data(16,:))
plot(diff(EEG.data(16,:)))
plot(diff(EEG.data(16,:)).^2)
edit HR2HRchangeZurich.m
edit getHRfromICA.m
data = diff(EEG.data(16,:)).^2;
threshold = 2*stdECG
stdECG = std(data);
stdECG = std(data)
threshold = 2*stdECG;
temp = data;
srate = 400;
time = 0:1000/srate:length(temp).*1000/srate-1000/srate;
Rchange=  find(data > threshold)
Rstamps = [Rchange(find(diff(Rchange)>125)) Rchange(end)];
Rstamps
plot(data)
hold on
plot(Rstamps, max(data)./2, 'r*')
plot(Rstamps(10), max(data)./2, 'go')
onsets = Rstamps(10:end);
dataall = EEG.data;
for trial = 1:42;
data3d(:, :, trial) = dataall(:, onsets(trial)-400:onsets(trial)+800);
end
ERP = mean(data3d, 3);
plot(ERP')
plot(ERP(21,:, :)')
Rstamps(10:end);
Rstamps(10:end)
plot(data)
plot(Rstamps, max(data)./2, 'r*')
hold on
plot(data)
whos
EEG
figure, plot(data(Rstamps(10)-400:Rstamps(10)+800);
figure, plot(data(Rstamps(10)-400:Rstamps(10)+800));
for trial = 1:50, plot(data(Rstamps(trial)-400:Rstamps(trial)+800)); pause, end
for trial = 1:50, plot(data(Rstamps(trial)-400):Rstamps(trial)+800)); pause, end
Rstamps(trial)-400
for trial = 2:50, plot(data(Rstamps(trial)-400:Rstamps(trial)+800)); pause, end
dataall = EEG.data;
for trial = 10:50;
data3d(:, :, trial) = dataall(:, onsets(trial)-400:onsets(trial)+800); plot(data3d(:, :, trial)'), pause
end
data3d = []; for onset = 1:42;
data3d(:, :, trial) = dataall(:, onsets(trial)-400:onsets(trial)+800); plot(data3d(:, :, trial)'), pause
end
data3d = []; for onset = 1:42;
data3d(:, :, onset) = dataall(:, onsets(onset)-400:onsets(onset)+800); plot(data3d(:, :, onset)'), pause
end
save data3draw.mat data3d -mat
save data3drawmin1to2.mat data3d -mat
plot(data3d(:, :, 1))
plot(data3d(:, :, 1)')
plot(data3d(1, :, :)')
plot(data3d(1, :, :))
plot(squeeze(data3d(1, :, :)))
plot(squeeze(data3d(2, :, :)))
plot(squeeze(data3d(3, :, :)))
plot(squeeze(data3d(4, :, :)))
EEG.chanlocs.labels
plot(squeeze(data3d(5, :, :)))
plot(squeeze(data3d(5, :, 1)))
for trial = 1:42;
plot(squeeze(data3d(5, :, trial))), title(num2str(trial)), pause, end
data3dfilt = data3d;
data2dfiltchanFz = squeeze(data3d(5,:, :));
data2dfiltchanFz = squeeze(data3d(5,:, :)');
data2dfiltchanFz = squeeze(data3d(5,:, :))';
data2dfiltchanFz = squeeze(data3d(5,:, :));
200.*.1
200.*.15
[lowa, lowb] = butter(3, .15)
plot(lowa)
plot(lowb)
data2dfiltchanFz_low = filtfilt(a, b, data2dfiltchanFz);
data2dfiltchanFz_low = filtfilt(lowa, lowb, data2dfiltchanFz);
plot(data2dfiltchanFz_low')
plot(data2dfiltchanFz_low)
[higha, highb] = butter(2, .01, 'high')
[higha, highb] = butter(2, .005, 'high')
data2dfiltchanFz_lowhigh = filtfilt(higha, highb, data2dfiltchanFz_low);
plot(data2dfiltchanFz_lowhigh)
data2dfiltchanFz_filteredandclean = data2dfiltchanFz_lowhigh(:, [1 2 3 4 5 6 7 8 11 12 13 14 15 16 17 19 20 22 23 25 26 29 30 31 32 33 38 39 40 41 42])
whos
plot(data2dfiltchanFz_filteredandclean)
data3dFzclean = zeros(1, 1201, 31);
data3dFzclean(1, :, :) = data2dfiltchanFz_filteredandclean;
edit wavelet_app_mat.m
[WaPower, PLI, PLIdiff] = wavelet_app_mat(data3dFzclean, 400, 10, 100, 3, [], 'test');
taxis = -1000:2.5:2000;
faxisall = 0:0.3333: 200;
faxis = faxisall(10:3:100)
[WaPower, PLI, PLIdiff] = wavelet_app_mat(data3dFzclean, 400, 6, 110, 3, [], 'test');
[WaPower, PLI, PLIdiff] = wavelet_app_mat(data3dFzclean, 400, 3, 110, 3, [], 'test');
[WaPower, PLI, PLIdiff] = wavelet_app_mat(data3dFzclean, 400, 4, 110, 3, [], 'test');
faxis = faxisall(4:3:110)
contourf(taxis, faxis, squeeze(WaPower(1,:,:)))
contourf(taxis, faxis, squeeze(WaPower(1,:,:))')
WaPowerBsl = bslcorrWAMat_div(WaPower, [150:300]);
contourf(taxis, faxis, squeeze(WaPowerBsl(1,:,:))')
contourf(taxis(200:1000), faxis, squeeze(WaPowerBsl(1,200:1000,:))')
colorbar
whos
plot(mean(data2dfiltchanFz_filteredandclean, 2))
contourf(taxis(200:1000), faxis, squeeze(WaPowerBsl(1,200:1000,:))')
edit get_FFT_mat3d
get_FFT_mat3d(data3dFzclean, 100:1100, 400);
FFT_spectrum3D(data3dFzclean, 100:1100, 400);
pow= FFT_spectrum3D(data3dFzclean, 100:1100, 400);
edit FFT_spectrum3D
[pow, freqs]= FFT_spectrum3D(data3dFzclean, 100:1100, 400);
plot(freqs(1:60), pow(1:60))