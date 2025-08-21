function [] = gaborgen_trialalpha_ak(EEGmatfile)

tmp = load(EEGmatfile); 
data = tmp.EEG.data;

figure(101); 
subplot(4,1,1), plot(tmp.EEG.times, squeeze(data(20, :, :)))

[ampout3d1, phaseout3d, freqs] = FFT_spectrum3D_singtrial(data, 361:961, 600, 1:100);
[ampout3d2, phaseout3d, freqs] = FFT_spectrum3D_singtrial(data, 961:1561, 600, 1:100);

subplot(4,1,2), plot(freqs(1:50), squeeze(ampout3d2(20, 1:50, :)))
