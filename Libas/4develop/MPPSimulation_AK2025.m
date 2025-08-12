%% settings shared for all loops and test
clear 
tic
% filters for alpha band
[a, b] = butter(5, 0.026);
[ahigh, bhigh] = butter(5, 0.015, 'high');

% other settings
time = 0.001:0.001:5.5; 
zerosig = zeros(size(time)); 
ntrials = 150;
nSNRs = 40; 
outmat = zeros(nSNRs, 9); 

% Blend: alpha controls asymmetry (0=pure sine, 1=pure sawtooth)
alpha = 1;                % Adjust between 0 and 1 to vary asymmetry

% M for MPP
M = 100; 

%  axes
faxisall = 0:0.1818:500; 

% loop over the next steps to make 30 trials
epochmat = zeros(ntrials, 5500); 

% loop over SNRfactors

for SNR = 1:1:nSNRs

    SNRfactor = ((SNR-1.1) +.1)./5; 

    for trial = 1:ntrials

        % make brownian noise
        whitesig = randn(size(time));
        brownsig = cumsum(detrend(whitesig));  % Brownian noise is the cumulative sum of white noise

        % make test signal
        randfreq = 9.5+rand(1,1); 
        sinwave = SNRfactor.*sin(2*pi*[0.001:0.001:.5]*randfreq);
        sawwave = SNRfactor.*sawtooth(2*pi*[0.001:0.001:.5]*randfreq);
        signal = (1-alpha)*sinwave + alpha*sawwave;

        addsig = zerosig;
        jitter = round(rand(1,1) * 40);
        addsig(2481+jitter:2980+jitter) = signal;
        epochmat(trial, :) =  addsig + brownsig;

    end

    % wavelet analysis
    mat3d = zeros(1,5500, ntrials);
    mat3d(1, :, :) = epochmat';
    WaPower = squeeze(wavelet_app_mat_singtrials(mat3d, 1000, 56, 56, 1));

    % convert to dB
    noise_indices = [1:2499, 3001:5500];
    noise = var(WaPower(noise_indices, :));
    WaPower_db = 20 * log10(zero_negatives(bslcorr(WaPower', 1000:2000)' ./ noise));

    % hits wavelet
    trialswithhits_wav = find(max(WaPower_db(2600:2900, :)) > 3);

    % falsealarms wavelet
    trialswithfalsealarms_wav = find(max(WaPower_db(3600:3900, :)) > 3);

    % MPP
    % filter the data
    epochmat_filt = filtfilt(a,b,epochmat')'; %
    epochmat_filt = filtfilt(ahigh,bhigh,epochmat_filt')';

    % do the MPP; ak replaced smooth.m with smoothdata.m
    [D,MPP,th_opt,ar,bw] = PhEv_Learn_fast_2(epochmat_filt, M, 7);

    % initiate hits and FAs
    trialswithhits_MPP = [];
    trialswithfalsealarms_MPP = [];

    %collect all taus
    tauvector = [];
    for tauindex = 1:size(MPP,2)
        taus = arrayfun(@(t) t.tau, MPP(tauindex).Trials);
        if any(taus > 2600 & taus < 2900), trialswithhits_MPP = [trialswithhits_MPP tauindex]; end
        if any(taus > 3600 & taus < 3900), trialswithfalsealarms_MPP = [trialswithfalsealarms_MPP tauindex]; end
    end

    % collect the info for this SNR
    hitrate_wav = length(trialswithhits_wav)./ntrials; 
    FArate_wav = length(trialswithfalsealarms_wav)./ntrials; 

    hitrate_MPP = length(trialswithhits_MPP)./ntrials; 
    FArate_MPP = length(trialswithfalsealarms_MPP)./ntrials; 

    d_prime_MPP = norminv(hitrate_MPP) - norminv(FArate_MPP);  % these estimates for d' and AUC are only approximations
    d_prime_wav = norminv(hitrate_wav) - norminv(FArate_wav);

    AUC_MPP = normcdf(d_prime_MPP / sqrt(2));
    AUC_wav = normcdf(d_prime_wav / sqrt(2));

    outmat(SNR, :) = [SNRfactor hitrate_wav FArate_wav d_prime_wav AUC_wav hitrate_MPP FArate_MPP d_prime_MPP AUC_MPP]; 

    disp(['SNR: ' num2str(SNRfactor)])

end

  totalduration = toc; 
  disp(['this took ' num2str(totalduration./60) ' minutes'])

  %% initial test plots
  close all
  figure(101), plot(outmat(:, 1), outmat(:, 2)), hold on, plot(outmat(:, 1), outmat(:,3)), legend('detections in test wave', ' detections in control wave', 'Location','northwest')
  figure(102), plot(outmat(:, 1), outmat(:, 6)), hold on, plot(outmat(:, 1), outmat(:,7)), legend('detections in test MPP', 'detections in contro MPP', 'Location','northwest')
  figure(103), plot(outmat(:, 1), outmat(:, 2)), hold on, plot(outmat(:, 1), outmat(:,6)), legend('detections wave', 'detections MPP', 'Location','northwest')
  figure(104), plot(outmat(:, 1), outmat(:, 3)), hold on, plot(outmat(:, 1), outmat(:,7)), legend('FA wave', 'FA MPP', 'Location','northwest')
  figure(105), plot(outmat(:, 1), outmat(:, 4)), hold on, plot(outmat(:, 1), outmat(:,8)), legend('Dprime wave', 'Dprime MPP', 'Location','northwest')
  figure(106), plot(outmat(:, 1), outmat(:, 5)), hold on, plot(outmat(:, 1), outmat(:,9)), legend('AUC wave', 'AUC MPP', 'Location','northwest')
%% load data for actual plots
orange = [1 0.5 0.0];
teal = [0.2 0.8 1];

% sine wave templates
% compare detections in the test period and the control period by SNR
M100sin = load('outmat_M100_sintemplate_3dB_thres.mat'); M100sin.outmat(:, 2:end) = movmean(M100sin.outmat(:, 2:end), 7, 1); 
M125sin = load('outmat_M125_sintemplate_3dB_thres.mat'); M125sin.outmat(:, 2:end) = movmean(M125sin.outmat(:, 2:end), 7, 1); 
M150sin = load('outmat_M150_sintemplate_3dB_thres.mat'); M150sin.outmat(:, 2:end) = movmean(M150sin.outmat(:, 2:end), 7, 1); 
M200sin = load('outmat_M200_sintemplate_3dB_thres.mat'); M200sin.outmat(:, 2:end) = movmean(M200sin.outmat(:, 2:end), 7, 1); 
M300sin = load('outmat_M300_sintemplate_3dB_thres.mat'); M300sin.outmat(:, 2:end) = movmean(M300sin.outmat(:, 2:end), 7, 1); 

%% WAVELETS
figure(101), title('Morlet wavelets'), hold on,  xlabel('Signal-to-Noise Ratio'), ylabel('Proportion Detected Events')
% calculate mean and range across repetitions, make shaded error bar
hitrates_wav_all = [M100sin.outmat(:, 2) M125sin.outmat(:, 2) M150sin.outmat(:, 2) M200sin.outmat(:, 2) M300sin.outmat(:, 2)]; 
FArates_wav_all =  [M100sin.outmat(:, 3) M125sin.outmat(:, 3) M150sin.outmat(:, 3) M200sin.outmat(:, 3) M300sin.outmat(:, 3)]; 
s1 = shadedErrorBar(M100sin.outmat(:, 1)./2, mean(hitrates_wav_all'), range(hitrates_wav_all'), 'transparent', 1,'patchSaturation',0.55, 'lineprops', {'-', 'Color', orange}); axis([-.1 4 0 1]);
s1.mainLine.LineWidth = 3;
s1.patch.FaceColor = orange;

s2 = shadedErrorBar(M100sin.outmat(:, 1)./2, mean(FArates_wav_all'), range(FArates_wav_all'), 'transparent', 1, 'patchSaturation',0.55, 'lineprops', {'-', 'Color', teal}); axis([-.1 4 0 1]);
s2.mainLine.LineWidth = 3;
s2.patch.FaceColor = teal;
legend('Test Period', 'Control Period', 'Location','east', 'fontsize', 18 )
ax = gca;
ax.FontSize = 18;            % increases size of tick labels
ax.XLabel.FontSize = 20;     % increases x-label font size
ax.YLabel.FontSize = 20;     % increases y-label font size
ax.Title.FontSize = 22;      % increases title font size

%% MPP
figure(102), title('MPP'), hold on, xlabel('Signal-to-Noise Ratio'), ylabel('Proportion Detected Events')
% calculate mean and range across repetitions, make shaded error bar
hitrates_MPP_all = [M100sin.outmat(:, 6) M125sin.outmat(:, 6) M150sin.outmat(:, 6) M200sin.outmat(:, 6) M300sin.outmat(:, 6)]; 
FArates_MPP_all =  [M100sin.outmat(:, 7) M125sin.outmat(:, 7) M150sin.outmat(:, 7) M200sin.outmat(:, 7) M300sin.outmat(:, 7)]; 
s1 = shadedErrorBar(M100sin.outmat(:, 1)./2, mean(hitrates_MPP_all'), range(hitrates_MPP_all'), 'transparent', 1,'patchSaturation',0.55, 'lineprops', {'-', 'Color', orange}); axis([-.1 4 0 1]);
s1.mainLine.LineWidth = 3;
s1.patch.FaceColor = orange;

s2 = shadedErrorBar(M100sin.outmat(:, 1)./2, mean(FArates_MPP_all'), range(FArates_MPP_all'), 'transparent', 1, 'patchSaturation',0.55, 'lineprops', {'-', 'Color', teal}); axis([-.1 4 0 1]);
s2.mainLine.LineWidth = 3;
s2.patch.FaceColor = teal;
legend('Test Period', 'Control Period', 'Location','east', 'fontsize', 18 )
ax = gca;
ax.FontSize = 18;            % increases size of tick labels
ax.XLabel.FontSize = 20;     % increases x-label font size
ax.YLabel.FontSize = 20;     % increases y-label font size
ax.Title.FontSize = 22;      % increases title font size

%%
figure(103), title('MPP detection in test period'), xlabel('Signal-to-Noise Ratio'), ylabel('Proportion Detected Events')
hold on,  plot(M100sin.outmat(:, 1)./2, M100sin.outmat(:, 6)),  axis([-.1 4 0 1]);
plot(M125sin.outmat(:, 1)./2, M125sin.outmat(:, 6)),  axis([-.1 4 0 1]);
plot(M150sin.outmat(:, 1)./2, M150sin.outmat(:, 6)),  axis([-.1 4 0 1]);
plot(M200sin.outmat(:, 1)./2, M200sin.outmat(:, 6)),  axis([-.1 4 0 1]);
plot(M300sin.outmat(:, 1)./2, M300sin.outmat(:, 6)),  axis([-.1 4 0 1]); legend('M=100',  'M=125', 'M=150', 'M=200', 'M=300', 'Location','east')

ax = gca;
ax.FontSize = 18;            % increases size of tick labels
ax.XLabel.FontSize = 20;     % increases x-label font size
ax.YLabel.FontSize = 20;     % increases y-label font size
ax.Title.FontSize = 22;      % increases title font size

figure(1003)
bar([M100sin.outmat(20, 6) M125sin.outmat(20, 6) M150sin.outmat(20, 6) M200sin.outmat(20, 6) M300sin.outmat(20, 6)])
%%

figure(104), title('MPP detection in control period')
hold on,  plot(M100sin.outmat(:, 1), M100sin.outmat(:, 7)), axis([-.5 8 0 1]); 
plot(M150sin.outmat(:, 1), M150sin.outmat(:, 7)), axis([-.5 8 0 1]); 
plot(M125sin.outmat(:, 1), M125sin.outmat(:, 7)), axis([-.5 8 0 1]); 
plot(M200sin.outmat(:, 1), M200sin.outmat(:, 7)), axis([-.5 8 0 1]); 
plot(M300sin.outmat(:, 1), M300sin.outmat(:, 7)), axis([-.5 8 0 1]); legend('M=100', 'M=150', 'M=200', 'M=300', 'Location','east')

%% sawtooth wave templates
orange = [1 0.5 0];
teal = [0 0.5 1];
% 
% compare detections in the test period and the control period by SNR
M100saw = load('outmat_M100_sawtemplate_3dB_thres.mat'); M100saw.outmat(:, 2:end) = movmean(M100saw.outmat(:, 2:end), 5, 1); 
M125saw = load('outmat_M150_sawtemplate_3dB_thres.mat'); M125saw.outmat(:, 2:end) = movmean(M125saw.outmat(:, 2:end), 5, 1); 
M150saw = load('outmat_M150_sawtemplate_3dB_thres.mat'); M150saw.outmat(:, 2:end) = movmean(M150saw.outmat(:, 2:end), 5, 1); 
M200saw = load('outmat_M200_sawtemplate_3dB_thres.mat'); M200saw.outmat(:, 2:end) = movmean(M200saw.outmat(:, 2:end), 5, 1); 
M300saw = load('outmat_M300_sawtemplate_3dB_thres.mat'); M300saw.outmat(:, 2:end) = movmean(M300saw.outmat(:, 2:end), 5, 1); 

figure(101), title('Morlet wavelets')
hold on,  plot(M100saw.outmat(:, 1), M100saw.outmat(:, 2), 'color', orange), hold on, plot(M100saw.outmat(:, 1), M100saw.outmat(:,3),  'color', teal), axis([-.5 8 0 1]); 
plot(M125saw.outmat(:, 1), M125saw.outmat(:, 2),  'color', orange), hold on, plot(M125saw.outmat(:, 1), M125saw.outmat(:,3),  'color', teal), axis([-.5 8 0 1]); 
plot(M150saw.outmat(:, 1), M150saw.outmat(:, 2),  'color', orange), hold on, plot(M150saw.outmat(:, 1), M150saw.outmat(:,3),  'color', teal), axis([-.5 8 0 1]); 
plot(M200saw.outmat(:, 1), M200saw.outmat(:, 2),  'color', orange), hold on, plot(M200saw.outmat(:, 1), M200saw.outmat(:,3),  'color', teal), axis([-.5 8 0 1]); 
plot(M300saw.outmat(:, 1), M300saw.outmat(:, 2),  'color', orange), hold on, plot(M300saw.outmat(:, 1), M300saw.outmat(:,3),  'color', teal), axis([-.5 8 0 1]); legend('in test period', 'in control period', 'Location','east')

figure(102), title('MPP')
hold on,  plot(M100saw.outmat(:, 1), M100saw.outmat(:, 6), 'color', orange), hold on, plot(M100saw.outmat(:, 1), M100saw.outmat(:,7),  'color', teal), axis([-.5 8 0 1]); 
plot(M125saw.outmat(:, 1), M125saw.outmat(:, 6),  'color', orange), hold on, plot(M125saw.outmat(:, 1), M125saw.outmat(:,7),  'color', teal), axis([-.5 8 0 1]); 
plot(M150saw.outmat(:, 1), M150saw.outmat(:, 6),  'color', orange), hold on, plot(M150saw.outmat(:, 1), M150saw.outmat(:,7),  'color', teal), axis([-.5 8 0 1]); 
plot(M200saw.outmat(:, 1), M200saw.outmat(:, 6),  'color', orange), hold on, plot(M200saw.outmat(:, 1), M200saw.outmat(:,7),  'color', teal), axis([-.5 8 0 1]); 
plot(M300saw.outmat(:, 1), M300saw.outmat(:, 6),  'color', orange), hold on, plot(M300saw.outmat(:, 1), M300saw.outmat(:,7),  'color', teal), axis([-.5 8 0 1]); legend('in test period', 'in control period', 'Location','east')

figure(103), title('MPP detection in test period')
hold on,  plot(M100saw.outmat(:, 1), M100saw.outmat(:, 6)), axis([-.5 8 0 1]); 
plot(M125saw.outmat(:, 1), M125saw.outmat(:, 6)), axis([-.5 8 0 1]); 
plot(M150saw.outmat(:, 1), M150saw.outmat(:, 6)), axis([-.5 8 0 1]); 
plot(M200saw.outmat(:, 1), M200saw.outmat(:, 6)), axis([-.5 8 0 1]); 
plot(M300saw.outmat(:, 1), M300saw.outmat(:, 6)), axis([-.5 8 0 1]); legend('M=100', 'M=150', 'M=200', 'M=300', 'Location','east')

figure(104), title('MPP detection in control period')
hold on,  plot(M100saw.outmat(:, 1), M100saw.outmat(:, 7)), axis([-.5 8 0 1]); 
plot(M125saw.outmat(:, 1), M125saw.outmat(:, 7)), axis([-.5 8 0 1]); 
plot(M150saw.outmat(:, 1), M150saw.outmat(:, 7)), axis([-.5 8 0 1]); 
plot(M200saw.outmat(:, 1), M200saw.outmat(:, 7)), axis([-.5 8 0 1]); 
plot(M300saw.outmat(:, 1), M300saw.outmat(:, 7)), axis([-.5 8 0 1]); legend('M=100', 'M=150', 'M=200', 'M=300', 'Location','east')

%% M100 plots: sine
close all
M100sin = load('outmat_M100_sintemplate_3dB_thres.mat'); M100sin.outmat(:, 2:end) = movmean(M100sin.outmat(:, 2:end), 5, 1); 
 figure(101), plot(M100sin.outmat(:, 1), M100sin.outmat(:, 2)), hold on, plot(M100sin.outmat(:, 1), M100sin.outmat(:,3)), axis([-.5 8 0 1]), legend('detections in test wave', ' detections in control wave', 'Location','northwest')
  figure(102), plot(M100sin.outmat(:, 1), M100sin.outmat(:, 6)), hold on, plot(M100sin.outmat(:, 1), M100sin.outmat(:,7)), axis([-.5 8 0 1]), legend('detections in test MPP', 'detections in contro MPP', 'Location','northwest')
  figure(103), plot(M100sin.outmat(:, 1), M100sin.outmat(:, 2)), hold on, plot(M100sin.outmat(:, 1), M100sin.outmat(:,6)), legend('detections wave', 'detections MPP', 'Location','northwest')
  figure(104), plot(M100sin.outmat(:, 1), M100sin.outmat(:, 3)), hold on, plot(M100sin.outmat(:, 1), M100sin.outmat(:,7)), legend('FA wave', 'FA MPP', 'Location','northwest')
  figure(105), plot(M100sin.outmat(:, 1), M100sin.outmat(:, 4)), hold on, plot(M100sin.outmat(:, 1), M100sin.outmat(:,8)), legend('Dprime wave', 'Dprime MPP', 'Location','northwest')
  figure(106), plot(M100sin.outmat(:, 1), M100sin.outmat(:, 5)), hold on, plot(M100sin.outmat(:, 1), M100sin.outmat(:,9)), legend('AUC wave', 'AUC MPP', 'Location','northwest')

  %% M100 plots: saw
close all
M100saw = load('outmat_M100_sawtemplate_3dB_thres.mat'); M100saw.outmat(:, 2:end) = movmean(M100saw.outmat(:, 2:end), 5, 1); 
 figure(101), plot(M100saw.outmat(:, 1), M100saw.outmat(:, 2)), hold on, plot(M100saw.outmat(:, 1), M100saw.outmat(:,3)), axis([-.5 8 0 1]), legend('detections in test wave', ' detections in control wave', 'Location','northwest')
  figure(102), plot(M100saw.outmat(:, 1), M100saw.outmat(:, 6)), hold on, plot(M100saw.outmat(:, 1), M100saw.outmat(:,7)), axis([-.5 8 0 1]), legend('detections in test MPP', 'detections in contro MPP', 'Location','northwest')
  figure(103), plot(M100saw.outmat(:, 1), M100saw.outmat(:, 2)), hold on, plot(M100saw.outmat(:, 1), M100saw.outmat(:,6)), legend('detections wave', 'detections MPP', 'Location','northwest')
  figure(104), plot(M100saw.outmat(:, 1), M100saw.outmat(:, 3)), hold on, plot(M100saw.outmat(:, 1), M100saw.outmat(:,7)), legend('FA wave', 'FA MPP', 'Location','northwest')
  figure(105), plot(M100saw.outmat(:, 1), M100saw.outmat(:, 4)), hold on, plot(M100saw.outmat(:, 1), M100saw.outmat(:,8)), legend('Dprime wave', 'Dprime MPP', 'Location','northwest')
  figure(106), plot(M100saw.outmat(:, 1), M100saw.outmat(:, 5)), hold on, plot(M100saw.outmat(:, 1), M100saw.outmat(:,9)), legend('AUC wave', 'AUC MPP', 'Location','northwest')

%% M100 plots: cube
load('shortsnr0246outmat_M100_cubetemplate_3dB_thres'); 
outmat = outmat(1:10:end,:);
 figure(101), plot(outmat(:, 1), outmat(:, 2)), hold on, plot(outmat(:, 1), outmat(:,3)), axis([-.5 8 0 1]), legend('detections in test wave', ' detections in control wave', 'Location','northwest')
  figure(102), plot(outmat(:, 1), outmat(:, 6)), hold on, plot(outmat(:, 1), outmat(:,7)), axis([-.5 8 0 1]), legend('detections in test MPP', 'detections in contro MPP', 'Location','northwest')
  figure(103), plot(outmat(:, 1), outmat(:, 2)), hold on, plot(outmat(:, 1), outmat(:,6)), legend('detections wave', 'detections MPP', 'Location','northwest')
  figure(104), plot(outmat(:, 1), outmat(:, 3)), hold on, plot(outmat(:, 1), outmat(:,7)), legend('FA wave', 'FA MPP', 'Location','northwest')
  figure(105), plot(outmat(:, 1), outmat(:, 4)), hold on, plot(outmat(:, 1), outmat(:,8)), legend('Dprime wave', 'Dprime MPP', 'Location','northwest')
  figure(106), plot(outmat(:, 1), outmat(:, 5)), hold on, plot(outmat(:, 1), outmat(:,9)), legend('AUC wave', 'AUC MPP', 'Location','northwest')


%%
function y = zero_negatives(x)
    y = x;
    y(y < 0) = 0;
end