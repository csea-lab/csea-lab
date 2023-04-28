function [dataout, datastruc4winmat] = shreadpostpro(datfilepath, setfilepath_p, setfilepath_i)

 cd '/Volumes/G-RAID Thunderbolt 3/As_Exps/SHREAD_epoch_setfiles'

%eeglab  % open eeglab

PLImat = [];

[convec] = SHREAD_getcontrial(datfilepath);  % get conditions in experiment, there can be various numbers of trials

% load the EEG for parent and infant 
EEG_p = pop_loadset(setfilepath_p);
EEG_i = pop_loadset(setfilepath_i);

% how many trials in each
trialsinEEG_p = size(EEG_p.epoch, 2);
trialsinEEG_i = size(EEG_i.epoch, 2);

% find common trials and indices
for x1 = 1:trialsinEEG_p
indexinEEG_p(x1) = str2num(EEG_p.epoch(x1).eventdescription)
end

for x2 = 1:trialsinEEG_i
indexinEEG_i(x2) = str2num(EEG_i.epoch(x2).eventdescription);
end

% find the trials that are available
commontrials = intersect(indexinEEG_p, indexinEEG_i); 

 % find the conditions of the trials that are available
conditionscommontrials = convec(commontrials);

% now find these common trials in each file and make into one matrix
dataout = []; 
for x3 = 1:size(commontrials, 2)

    %find trials with that original index, i.e trials that belong together
     index_p = find(commontrials(x3)==indexinEEG_p);
     index_i = find(commontrials(x3)==indexinEEG_i);

     temp_p = EEG_p.data(:, :, index_p); 
     temp_i = EEG_i.data(:, :, index_i); 

     dataout(:, :, x3) = [temp_p;temp_i]; 

end

% find conditions for each trial and make submatrices
conditions = unique(convec)

for con = 1:length(conditions)
    
   trialselectindex = find(conditionscommontrials == conditions(con));
     
   datastruc4winmat(con).con3d = dataout(:, :, trialselectindex); 
   
   [outmat5Hz] = freqtag_slidewin_intersite(dataout(:, :, trialselectindex), 0, 1:51, 50:1550, 5, 600, 500, 75, [setfilepath_p(1:13) '.5Hz.' num2str(conditions(con))]);
   [outmat6Hz] = freqtag_slidewin_intersite(dataout(:, :, trialselectindex), 0, 1:51, 50:1550, 6, 600, 500, 75, [setfilepath_p(1:13) '.6Hz.' num2str(conditions(con))]); 
   
end







