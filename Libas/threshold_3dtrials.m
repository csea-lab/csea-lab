function [ inmat3d, badindex, NGoodtrials ] = threshold_3dtrials(inmat3d, threshold)
% caluclate three metrics of data quality at the trial level

    absvalvec = squeeze(median(median(abs(inmat3d),2'))); % Median absolute voltage value for each trial
    
    badindex = find(absvalvec > threshold);
    
    inmat3d(:, :, badindex) = []; 
    
    NGoodtrials = size(inmat3d,3);



