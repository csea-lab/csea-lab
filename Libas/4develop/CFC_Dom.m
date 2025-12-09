% script for reashaping and then FFTing and the P2Acoupling with OCA alpha
% data for DOM
% settings:
SampRate = 500;
thresholdTrials = 1.25;

%% load data and reshape into 2-second segments
cd /Users/andreaskeil/Desktop/tempdata/Dom_alpha_testOct2025
load('OCA_3139.trls.1.mat') % loads our example data set
size(Mat3D);
data = reshape(Mat3D, [257, 1000, 62]);
%% throw out bad segments
disp('artifact handling: epochs')
[data, badindexvec, NGoodtrials ] = scadsAK_3dtrials(data, thresholdTrials);
size(data)
%% FFT
[specavg, freqs] = FFT_spectrum3D(data, 1:1000, 500);
figure, plot(freqs(3:60), specavg(:, 3:60))

%% phase 2 amp coupling
[CFCwithin, CFCacross, CFCwithin_norm, CFCacross_norm] = phaseampcouple_full(data, ...
    SampRate, 9, 39, 30, 2, 1, 1:1000, 0);

