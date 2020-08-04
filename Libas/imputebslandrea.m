function [ datamat_imp ] = imputebslandrea( datamat );
%takes out the stim artifact in LENS data

% first identify jittered timewindow which always includes 150th to 166th
% time point, variable in each trial

for trial = 1:size(datamat,3)
    
    trialdata = squeeze(datamat(:, :, trial)); 

    tpointstart = 110 + randperm(20); 
    tpointend = tpointstart + 55; 

    % the length is 36 points
    % to impute, we take the first 26 points from each segment

    imputation =  trialdata(:, 1:56) .* cosinwin(5, 56, 20); 

    segbefore = trialdata(:, 1:tpointstart) .* cosinwin(5, length(1:tpointstart), 20); 

    segafter = trialdata(:, tpointend:end) .* cosinwin(5, size(trialdata(:, tpointend:end), 2), 20); 

    segbefore = segbefore(:, 1:end-1); 
    segafter = segafter(:, 1:end-1); 

    datamat_imp(:, :, trial) = [segbefore imputation segafter];

end

