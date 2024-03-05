%% Calculate Grand Mean for MyAps pupil response %%
cd '/Users/csea/Documents/SarahLab/Sarah_Data/IAPs'


clear
filemat = getfilesindir(pwd, '*edf.pup.out.mat')
[avgmat] = avgmats_mat(filemat, 'GM55pupil8con.mat');

figure(101)
subplot(2,1,1), plot(avgmat(:, 1:3)), legend('pleasant', 'neutral', 'unpleasant')
title('6 Conditions')
subplot(2,1,2), plot(avgmat(:, 5:7)), legend('pleasant', 'neutral', 'unpleasant')
matoutbsl = bslcorr(avgmat', 300:500)'; 
xlabel('Time')
ylabel('Pupil Size')

figure(102) 
subplot(2,1,1), plot(matoutbsl(:, 1:3)), legend('pleasant', 'neutral', 'unpleasant')
title('Baseline Corrected')
subplot(2,1,2), plot(matoutbsl(:, 5:7)), legend('pleasant', 'neutral', 'unpleasant')
xlabel('Time')
ylabel('Pupil Size')


%% Calculate Grand Mean for MyAps pupil response %%
cd '/Users/csea/Documents/SarahLab/Sarah_Data/IAPs'


clear
filemat = getfilesindir(pwd, '*edf.pup.out.mat')
[avgmat] = avgmats_mat(filemat, 'GM55pupil8con.mat');

figure(101)
subplot(2,1,1), plot(avgmat(:, 1:3)), legend('pleasant', 'neutral', 'unpleasant')
title('6 Conditions')
xlim([1000 1500])  % Set x-axis limits for top subplot
subplot(2,1,2), plot(avgmat(:, 5:7)), legend('pleasant', 'neutral', 'unpleasant')
matoutbsl = bslcorr(avgmat', 300:500)'; 
xlim([1000 1500])  % Set x-axis limits for top subplot
xlabel('Time')
ylabel('Pupil Size')

figure(102) 
subplot(2,1,1), plot(matoutbsl(:, 1:3)), legend('pleasant', 'neutral', 'unpleasant')
title('Baseline Corrected')
xlim([1000 1500])  % Set x-axis limits for top subplot
subplot(2,1,2), plot(matoutbsl(:, 5:7)), legend('pleasant', 'neutral', 'unpleasant')
xlim([1000 1500])  % Set x-axis limits for top subplot
xlabel('Time')
ylabel('Pupil Size')
