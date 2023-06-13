function [matcorr, matout] = wurzburg_eye_pipeline(edffile, datfile)

datamat = Edf2Mat(edffile);
matfile = edffile;

% for epoching, code preSP and postSP
preSP = 500; % 1 second pre
postSP = 5500; % 11 seconds post

ntrials = 180; 

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

timestamps = datamat.Samples.time; % these are the time stamps in ms that match where the data are

% find indices for trial segmentation, i.e. timestamps of stim onsets
[test1, loc1] = ismember(startbins, timestamps);
[test2, loc2] = ismember(startbins-1, timestamps); % they might be off by one point
indices = loc1 + loc2;

% put in mat format chan (3) by time by trials.. important: 
%looks like ethernet message takes 200 ms to initialize and then send to eye link out of psychtoolbox
taxis = -preSP*2:2:postSP*2;
mat = zeros(postSP+preSP+1, ntrials);

for x = 1:size(startbins,2)
    mat(:, x) = datavec(indices(x)-preSP:indices(x)+postSP);
end

% plot the data
figure
for x = 1:ntrials
    plot(taxis, mat(:,x)'), title (['trial number:' num2str(x)]), pause(.1)
end


disp('artifact correction about to commence')
pause(1)


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
 percentbadvec(x)= (sum(isnan(datavec_corr(indices(x)-500:indices(x)+5500)))./length(mat(:,1))).*100; 
 end
 
 % replace all NaNs in x with linearly interpolated values
 datavec_corr(nans) = interp1(timestamps(~ nans), datavec_corr(~ nans), timestamps(nans), 'pchip');
 
 % put in mat format chan (3) by time by trials
 matcorr = zeros(postSP+preSP+1, ntrials);
 for x = 1:size(indices,2)
 matcorr(:, x) = datavec_corr(indices(x)-preSP:indices(x)+postSP);  
 
 
 % plot the data
 figure
 for x = 1:ntrials
 plot(taxis, matcorr(:,x)'), title (['CORRECTED - trial number:' num2str(x)]), pause(.1)
 end
 
 % now assign the conditions
 datfilemat = load(datfile); 
 conditionvec = datfilemat(:, 3); 
 
 % average by condition
 matout = zeros(postSP+preSP+1, 3); 
 
 for condition = 1:3
 matout(:, condition) = mean(matcorr(:, conditionvec==condition), 2); 
 end
 
 eval(['save ' matfile '.pup.out matout -mat'])
 
