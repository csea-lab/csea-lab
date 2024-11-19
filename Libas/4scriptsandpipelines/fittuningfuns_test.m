% fittuningfuns_test
clear all
cd '/home/laura/Documents/Gaborgen24'
load('/home/laura/Documents/Gaborgen24/keegan.mat')

options = statset('MaxIter', 100000, 'TolFun', 0.0001,  'Robust', 'off');

% first fit the grand mean and get parameter estimates
meankeegan = rangecorrect(mean(keegan))';

% first: ricker [amplitude] = Ricker(std, t)
t = -7:7;
%t = (-0.875:0.125:0.875).*5;
[BETA_rick,R_rick,J,COVB,MSE_rick] = nlinfit(t,meankeegan,@Ricker, [0.4], options);
[ricker_best_fit_amplitude] = Ricker(BETA_rick, t);
figure(101)
plot(t, meankeegan),
hold on
plot(t, ricker_best_fit_amplitude), legend('data', 'Ricker fit')

% second: morlet [amplitude] = Ricker(std, t)
[BETA_morl,R_morl,J,COVB,MSE_morl] = nlinfit(t,meankeegan,@TimeDomMorletWavelet, [0.4 1], options);
[morlet_best_fit_amplitude] = TimeDomMorletWavelet(BETA_morl, t);
figure(102)
plot(t, meankeegan),
hold on
plot(t, morlet_best_fit_amplitude), legend('data', 'Morlet fit')


%% bootstrap Ricker
BETA_brick = nan(1,5000);
BETA_brick_p = nan(1,5000);
R_brick = nan(15,5000);
R_brick_p = nan(15,5000);
MSE_brick = nan(1,5000);
MSE_brick_p = nan(1,5000);

for b_index = 1:5000
   % Real data 
    b_data = keegan(randi(9, 9, 1), :);
    b_mean = rangecorrect(mean(b_data))';
    [BETA_brick(b_index),R_brick(:,b_index),J,COVB,MSE_brick(b_index)] = ...
        nlinfit(t,b_mean,@Ricker, 0.4, options);
    % perm data
     b_mean_p = rangecorrect(mean(b_data))';
    % [BETA_brick_p(b_index),R_brick_p(:,b_index),J,COVB,MSE_brick_p(b_index)] = ...
    %     nlinfit(t,b_mean_p,@Ricker, 0.4, options);
    MSE_brick_p(b_index) = mean(b_mean_p.^2);

end


%% bootstrap Morlet
BETA_bmorl = nan(2,5000);
BETA_bmorl_p = nan(1,5000);
R_bmorl  = nan(15,5000);
R_bmorl_p = nan(15,5000);
MSE_bmorl  = nan(1,5000);
MSE_bmorl_p = nan(1,5000);

for b_index = 1:5000
   % Real data 
    b_data = keegan(randi(9, 9, 1), :);
    b_mean = rangecorrect(mean(b_data))';
    [BETA_bmorl(:, b_index),R_bmorl(:,b_index),J,COVB,MSE_bmorl(b_index)] = ...
        nlinfit(t,b_mean,@TimeDomMorletWavelet, [0.4 1], options);
    % perm data
     b_mean_p = rangecorrect(mean(b_data))';
    % [BETA_brick_p(b_index),R_brick_p(:,b_index),J,COVB,MSE_brick_p(b_index)] = ...
    %     nlinfit(t,b_mean_p,@Ricker, 0.4, options);
    MSE_bmorl_p(b_index) = mean(b_mean_p.^2);

end

%%

