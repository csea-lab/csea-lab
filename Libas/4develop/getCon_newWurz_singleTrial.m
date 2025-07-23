function [conditionvec] = getCon_newWurz_singleTrial(filepath)
% first, read in a new_wurz log file with RTs and everything
table = readtable(filepath);
conditionvec = table2array(table(:, 1));


% version for subjects with missing event markers 
missingTrials = containers.Map;
    missingTrials('New_Wurz_201.csv') = [1, 59, 212];
    missingTrials('New_Wurz_202.csv') = [165];
    missingTrials('New_Wurz_209.csv') = [132];
    missingTrials('New_Wurz_211.csv') = [46, 101];
    missingTrials('New_Wurz_213.csv') = [77];


% Check if this subject has missing trials
    if isKey(missingTrials, filepath)
        indices = missingTrials(filepath);
        conditionvec(indices) = [];
    end
