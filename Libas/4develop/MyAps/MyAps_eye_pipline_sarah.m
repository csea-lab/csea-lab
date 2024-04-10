function [matcorr, matout, matoutbsl, percentbadvec, percentbadsub, percentbadcond] = MyAps_eye_pipline_sarah(edffull, datafile, outname)

if nargin < 4 
    plotflag = 0; 
end

datamat = Edf2Mat(edffull);

conditionnames = [11 12 13 14 21 22 23 24];
conditionMapping = [1 2, 3, 4, 5, 6, 7, 8];

pupilbycond = [];

%to get the indices of a given message: here it is "cue on"

trialindexinMSGvec = []; 
 
 for x = 1:length(datamat.Events.Messages.info);
     if findstr('cue_on', char(datamat.Events.Messages.info(x)));
         trialindexinMSGvec = [trialindexinMSGvec datamat.Events.Messages.time(x)]; 
     end
 end;

startbins = trialindexinMSGvec; 
 
datavec = datamat.Samples.pupilSize;

% % % plot pupil vs trials: 
if plotflag
figure
plot(datamat.Samples.time, datavec)
hold on
plot(startbins, 200, '*')
end

%%%Added by Sarah%%%
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

% put in mat format chan (3) by time by trials.. important: 
%looks like ethernet message takes 200 ms to initialize and then send to eye link out of psychtoolbox
%Genface: bsl is __ samples (___ms), trial is 2000 samples (4000ms), 240 trials
%added 200ms to bsl
taxis = -1000:2:3000; %this is in ms
mat = zeros(2001, 240);

%% segmentation
for x = 1:size(startbins,2);
    mat(:, x) = datavec(indices(x)-500:indices(x)+1500);  %in sample points
end

% % plot the data
% figure
% for x = 1:240
% plot(taxis, mat(:,x)'), title (['trial number:' num2str(x)]), 
%     xlabel('Time (milliseconds)'), ylabel('Pupil Size'), pause(.1)
% end


disp('artifact correction about to commence')
%pause


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
 for x = 1:size(indices,2);
 totalbadvec(x)= sum(isnan(datavec_corr(indices(x)-1000:indices(x)+1800)));
 percentbadvec(x)= (sum(isnan(datavec_corr(indices(x)-1000:indices(x)+1800)))./length(mat(:,1))).*100; 
 end
 
 %find out how many NaNs per subject
 totaltrialtp = 2000*240;
 percentbadsub = sum(totalbadvec)/totaltrialtp;
 
 % replace all NaNs in x with linearly interpolated values
 datavec_corr(nans) = interp1(timestamps(~ nans), datavec_corr(~ nans), timestamps(nans), 'pchip');
 
 % put in mat format chan (3) by time by trials
 matcorr = zeros(2001, 240);
 for x = 1:size(indices,2);
 matcorr(:, x) = datavec_corr(indices(x)-500:indices(x)+1500);  
 end;
 
 % % plot the data
 figure
 for x = 1:240
 plot(taxis, matcorr(:,x)'), title (['CORRECTED - trial number:' num2str(x)]), 
 xlabel('Time (milliseconds)'), ylabel('Pupil Size'), pause(.1)
 end

 % now assign the conditions
[condvec] = getcon_MyAPSLPP_V3(datafile);

 %find out how many NaNs per condition for this subject
 percentbadcond = NaN(8,1);
 for cond =  1:8
     percentbadcond(cond) = sum(totalbadvec(condvec==condvec(cond)))/(2001*sum(condvec==condvec(cond)));
 end
 


% Initialize matout: 2000 samplepoints & 8 conditions for each participant
matout = zeros(2001, 8);

% Loop through conditions
for cond = 1:8;
    % Find the indices in condvec corresponding to the current cond
    indices = find(condvec == conditionnames(conditionMapping(cond)));

    % Check if there are any matching trials
    if isempty(indices);
        warning('No matching trials for condition %d', conditionMapping(cond));
    else
        % Calculate the mean across trials for the current condition
        matout(:, cond) = mean(matcorr(:, indices), 2)
        matoutbsl = bslcorr_div(matout', 300:500)';

    end
end


 save([outname '.pup.out.mat'], 'matout', '-mat');
 save([outname '.bsl.mat'], 'matoutbsl', '-mat');
 save([outname '.corr.mat'], 'matcorr', '-mat');
 save([outname '.percentbad.mat'], 'percentbadvec', 'percentbadsub', 'percentbadcond', '-mat') ;



%%condition averaged across trials by time for 6 (8 - 2 removed) conditions
figure(101)
subplot(2,1,1), plot(matout(:, 1:3),'LineWidth', 3), legend('pleasant', 'neutral', 'unpleasant')
title('6 Conditions')
subplot(2,1,2), plot(matout(:, 5:7),'LineWidth', 3), legend('pleasant', 'neutral', 'unpleasant')



% matoutbsl = bslcorr_div(matout', 300:500)';

%%baseline corrected averaged 6 conditions across trials  
figure(102) 
subplot(2,1,1), plot(taxis, matoutbsl(:, 1:3),'LineWidth', 3), legend('pleasant', 'neutral', 'unpleasant')
title('Baseline Corrected 6 Conditions')
subplot(2,1,2), plot(taxis, matoutbsl(:, 5:7),'LineWidth', 3), legend('pleasant', 'neutral', 'unpleasant')
end
 
% avgCond = mean(matout, 8);
% 
%  save([outname '.avgCond.mat'], 'avgCond', '-mat')
