function [diffampOz, meandiff] = gaborgen_trialalpha_ak(subjectID)

meandiff = zeros(1,8);
conditionvec = [11:14 21:24];

for conditionindex = 1:8

    EEGmatfile = [num2str(subjectID) '_' num2str(conditionvec(conditionindex)) '_NEW_EEG.mat'];

    tmp = load(EEGmatfile);
    data = tmp.EEG.data;

    [ data, badindex, NGoodtrials ] = scadsAK_3dtrials(data, 2); 

    badindex, pause

    figure(101);
    subplot(4,1,1), plot(tmp.EEG.times, squeeze(data(20, :, :))), axis([-1600 2000 min(min(data(20, :, :))) max(max(data(20, :, :)))]);
    title(['condition ' num2str(conditionvec(conditionindex)) ': voltage at Oz'])

    [ampout3d1, ~, freqs] = FFT_spectrum3D_singtrial(data, 361:961, 600, 1:100);
    [ampout3d2, ~] = FFT_spectrum3D_singtrial(data, 1161:1761, 600, 1:100);

    subplot(4,1,2), plot(freqs(1:50), squeeze(ampout3d1(20, 1:50, :))), title('baseline spectrum')
    subplot(4,1,3), plot(freqs(1:50), squeeze(ampout3d2(20, 1:50, :))), title('spectrum during Gabor')

    diffampOz= ampout3d2-ampout3d1; % figure, plot(freqs(1:50), squeeze(diffamp(20, 1:50, :)))

    subplot(4,1,4), bar(squeeze(mean(diffampOz(20, 9:14, :), 2))), title(['alpha power change from baseline'])

    meandiff(conditionindex) = mean(squeeze(mean(diffampOz(20, 9:14, :), 2)));

    pause

end

  figure(102), bar(meandiff), pause