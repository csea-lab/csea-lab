%%Function called by "Pupil_preproc.m" 
%%inputs edf file, sample rate, condition vector function, condition file names, name of trigger, pre stimulus onset timepoints, post simulus onset timepoints)
%%outputs: matcorr - timepoints by trials; matout - timepoints by condition; matoutbsl - matout baseline corrected, percentbad(-vec,-sub,-cond) - contains
    %%several stats on bad trials; avgcond - average over all trials per condition

function [matcorr, matout, matoutbsl, percentbadvec, percentbadsub, percentbadcond] = eye_pipeline(edffull, sRate, convecfun, confile, trigname, pre_onsetSP, post_onsetSP, plotflag)

datamat = Edf2Mat(edffull);

pupilbycond = [];

%test = ['convec =  ' convecfun '(''' confile ''')'];
%eval(test);

convec = feval(convecfun, confile);
Ntrials_con = length(convec); 

% calculate time information from the inputs
Sinterval = 1000/sRate; 
taxis = -pre_onsetSP*Sinterval:Sinterval:post_onsetSP*Sinterval; 
timepoints = length(taxis);

%  to get the indices of a given message: here it is trigname
%  intializes empty array, used to store time indices corresponding to messages with "trigname" text

trialindexinMSGvec = []; 
 
 for x = 1:length(datamat.Events.Messages.info)
     if findstr(trigname, char(datamat.Events.Messages.info(x)))
         trialindexinMSGvec = [trialindexinMSGvec datamat.Events.Messages.time(x)]; 
     end
 end

 % check number trials
 Ntrials_EDF = length(trialindexinMSGvec)

 if Ntrials_con ~= Ntrials_EDF, 
     error('trial counts in log file and in edf file do NOT match!')
 else 
     Ntrials = Ntrials_EDF; 
 end

startbins = trialindexinMSGvec; 
datavec = datamat.Samples.pupilSize;

% % plot pupil vs trials: 
figure
plot(datamat.Samples.time, datavec)
hold on
plot(startbins, 200, '*') %200 is random number above x-axis to see trial onset events
% Add labels for the x-axis and y-axis
xlabel('Time (milliseconds)')
ylabel('Pupil Size')
% Add a title to the plot
title('Pupil Size vs. Time and Trials')

timestamps = datamat.Samples.time; % these are the time stamps in ms that match where the data are

% find indices for trial segmentation, i.e. timestamps of stim onsets
[test1, loc1] = ismember(startbins, timestamps);
[test2, loc2] = ismember(startbins-1, timestamps); % they might be off by one point
indices = loc1 + loc2;

% put in mat format chan (3) by time by trials.. 
% important: looks like ethernet message takes 200 ms to initialize,
    % and then send to eye link out of psychtoolbox
%For example, in Genface: bsl is 400 samplepoints (800ms), trial is 1000 samples (2000ms), 291 trials
%added 200ms to bsl

mat = zeros(timepoints, Ntrials); %creates empty array, (timepoints per perticipant by trials per participant)

%MUST correspond to timepoints specified by taxis/timepoints variables
for x = 1:size(startbins,2)
    mat(:, x) = datavec(indices(x)-pre_onsetSP:indices(x)+post_onsetSP);  
end

% plot the data
if plotflag
    figure
    for x = 1:Ntrials
        plot(taxis, mat(:,x)'), title (['trial number:' num2str(x)]),
        xlabel('Time (milliseconds)'), ylabel('Pupil Size'), pause(.1)
    end
end

disp('artifact correction about to commence')
pause(.2)


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
 totalbadvec(x)= sum(isnan(datavec_corr(indices(x)-pre_onsetSP:indices(x)+post_onsetSP)));
 percentbadvec(x)= (sum(isnan(datavec_corr(indices(x)-pre_onsetSP:indices(x)+post_onsetSP)))./length(mat(:,1))).*100; 
 end
 
 %find out how many NaNs per subject
 totaltrialtp = timepoints*Ntrials;
 percentbadsub = sum(totalbadvec)/totaltrialtp;
 
 % replace all NaNs in x with linearly interpolated values
 datavec_corr(nans) = interp1(timestamps(~ nans), datavec_corr(~ nans), timestamps(nans), 'pchip');
 
 % put in mat format chan (3) by time by trials
 matcorr = zeros(timepoints, Ntrials);
 for x = 1:size(indices,2)
 matcorr(:, x) = datavec_corr(indices(x)-pre_onsetSP:indices(x)+post_onsetSP);  
 end
 
 % plot the data
 if plotflag
     figure
     for x = 1:Ntrials
         plot(taxis, matcorr(:,x)'), title (['CORRECTED - trial number:' num2str(x)]),
         xlabel('Time (milliseconds)'), ylabel('Pupil Size'), pause(.1)
     end
 end
 

 % % now assign the conditions
connames = unique(convec) 
numcond = length(unique(convec));
 
 % %find out how many NaNs per condition for this subject
  percentbadcond = NaN(numcond,1);
  for cond =  1:numcond
     percentbadcond(cond) = sum(totalbadvec(convec==connames(cond)))/(timepoints*sum(convec==connames(cond)));
  end
 
 % % average by condition
  matout = zeros(timepoints, numcond); 
 % 
  for condition = 1:numcond
  matout(:, condition) = mean(matcorr(:, convec==connames(condition)), 2); 
  matoutbsl = bslcorr(matout', 300:500)'; 
  end


%%condition averaged across trials by time for conditions
figure(101)
plot(matout(:, 1:numcond)), legend


%%baseline corrected averaged conditions across trials  
figure (102)
plot(taxis, matoutbsl(:, 1:numcond)), legend

save([edffull '.pup.out.mat'], 'matout', '-mat')
save([edffull '.percentbad.mat'], 'percentbadvec', 'percentbadsub', 'percentbadcond', '-mat') 

end % function
 
