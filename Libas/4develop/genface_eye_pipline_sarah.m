function [matcorr, matout, matoutbsl, matoutbsldiv, percentbadvec, percentbadsub, percentbadcond, avgCond] = genface_eye_pipline_sarah(edffull, datafile, edffile)

datamat = Edf2Mat(edffull);

pupilbycond = [];

%to get the indices of a given message: here it is "cue on"

trialindexinMSGvec = []; 
 
 for x = 1:length(datamat.Events.Messages.info)
     if findstr('cue_on', char(datamat.Events.Messages.info(x)))
         trialindexinMSGvec = [trialindexinMSGvec datamat.Events.Messages.time(x)]; 
     end
 end

startbins = trialindexinMSGvec; 
 
datavec = datamat.Samples.pupilSize;

% % plot pupil vs trials: 
figure
plot(datamat.Samples.time, datavec)
hold on
plot(startbins, 200, '*')

% Add labels for the x-axis and y-axis
xlabel('Time (milliseconds)')
ylabel('Pupil Size')
% Add a title to the plot
title('Pupil Size vs. Time and Trials')
%%%End of addition%%%


timestamps = datamat.Samples.time; % these are the time stamps in ms that match where the data are

% find indices for trial segmentation, i.e. timestamps of stim onsets
[test1, loc1] = ismember(startbins, timestamps);
[test2, loc2] = ismember(startbins-1, timestamps); % they might be off by one point
indices = loc1 + loc2;

% put in mat format chan (3) by time by trials.. 
% important: looks like ethernet message takes 200 ms to initialize,
    % and then send to eye link out of psychtoolbox
%Genface: bsl is 400 samplepoints (800ms), trial is 1000 samples (2000ms), 291 trials
%added 200ms to bsl
taxis = -1000:2:3600; %this is in ms
mat = zeros(2301, 291);

for x = 1:size(startbins,2)
    mat(:, x) = datavec(indices(x)-500:indices(x)+1800);  
end

% plot the data
figure
for x = 1:291
plot(taxis, mat(:,x)'), title (['trial number:' num2str(x)]), 
    xlabel('Time (milliseconds)'), ylabel('Pupil Size'), pause(.1)
end 

disp('artifact correction about to commence')
pause(.5)


% %%%%%%%%%%%%%
% artifact correct
 datavec_corr = datavec;

% identify points in each epoch were all are zero and set to nans
 ind_zeros =  find(datavec == 0);
 datavec_corr(ind_zeros) = NaN;

% identify points where pupli changes too fast and set to nans
 ind_slope =  find(abs(diff(datavec)) > 2.5);
 datavec_corr(ind_slope) = NaN;

% pick up the surrounding points after filtering
 [filta, filtb] = butter(6, .03);
 rawfilt = filtfilt(filta, filtb, abs(diff(datavec)));
 ind_nearslope =  find(rawfilt > 5);
 datavec_corr(ind_nearslope) = NaN;
 
 nans = isnan(datavec_corr); % make nans all the bad stuff and find indices of nans
 
% find out per trial how many NaNs
 for x = 1:size(indices,2)
 totalbadvec(x)= sum(isnan(datavec_corr(indices(x)-500:indices(x)+1800)));
 percentbadvec(x)= (sum(isnan(datavec_corr(indices(x)-500:indices(x)+1800)))./length(mat(:,1))).*100; 
 end
 
 %find out how many NaNs per subject
 totaltrialtp = 2301*291;
 percentbadsub = sum(totalbadvec)/totaltrialtp;
 
 % replace all NaNs in x with linearly interpolated values
 datavec_corr(nans) = interp1(timestamps(~ nans), datavec_corr(~ nans), timestamps(nans), 'pchip');
 
 % put in mat format chan (3) by time by trials
 matcorr = zeros(2301, 291);
 for x = 1:size(indices,2)
 matcorr(:, x) = datavec_corr(indices(x)-500:indices(x)+1800);  
 end

 % plot the data
 figure
 for x = 1:291
 plot(taxis, matcorr(:,x)'), title (['CORRECTED - trial number:' num2str(x)]), 
 xlabel('Time (milliseconds)'), ylabel('Pupil Size'), pause(.1)
 end

 % now assign the conditions
 datfilemat = readmatrix(datafile); 
 conditionvec = datfilemat(1:291, 4);
 conditionvec(1:floor(length(conditionvec)/2)) = conditionvec(1:floor(length(conditionvec)/2))+10;
 conditionvec(floor(length(conditionvec)/2+1):end) = conditionvec(floor(length(conditionvec)/2)+1:end)+20;
 condvec = [11:17,21:27];
 
 %find out how many NaNs per condition for this subject
 percentbadcond = NaN(14,1);
 for cond =  1:14
     percentbadcond(cond) = sum(totalbadvec(conditionvec==condvec(cond)))/(1501*sum(conditionvec==condvec(cond)));
 end
 

 % average by condition
 matout = zeros(2301, 14); 
 
 for condition = 1:14
 matout(:, condition) = mean(matcorr(:, conditionvec==condvec(condition)), 2); 
 end
 

 for condition = 1:14
 matoutbsl = bslcorr(matout', 300:500)'; %300 to 500 represents samplepoints before stimulus onset to average for baseline; 400 ms
 matoutbsldiv = bslcorrdivide(matout', 300:500)';
 end
 
 save([edffile '.pup.out.mat'], 'matout', '-mat')
 save([edffile '.corr.mat'], 'matcorr', '-mat')
 save([edffile '.percentbad.mat'], 'percentbadvec', 'percentbadsub', 'percentbadcond', '-mat') 
 save([edffile '.bsl.mat'], 'matoutbsl', '-mat')
 save([edffile '.bsldiv.mat'], 'matout', '-mat')

%%condition averaged across trials by time for 14 conditions
figure(101)
subplot(2,1,1), plot(matout(:, 1:7)), legend
title('14 Conditions')
subplot(2,1,2), plot(matout(:, 8:14)), legend



%%baseline corrected averaged 14 conditions across trials  
figure (102)
subplot(2,1,1), plot(taxis, matoutbsl(:, 1:7)), legend
title('14 Conditions Baseline Corrected')
subplot(2,1,2), plot(taxis, matoutbsl(:, 8:14)), legend
xlabel('Time (milliseconds)'), ylabel('Pupil Size')

%%baseline corrected w/division averaged 14 conditions across trials
figure (103)
subplot(2,1,1), plot(taxis, matoutbsldiv(:, 1:7)), legend
title('14 Conditions Baseline Corrected with Division')
subplot(2,1,2), plot(taxis, matoutbsldiv(:, 8:14)), legend
xlabel('Time (milliseconds)'), ylabel('Pupil Size')

avgCond = mean(matoutbsl, 1);

 save([edffile '.avgCond.mat'], 'avgCond', '-mat')

pause()
end
 
  
%genface_eye_pipline_sarah('GeF301.edf', 'genface_301.dat', 'GeF301'); - trial run with function 
 
