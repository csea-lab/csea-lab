function [ inmat3d, badindex, NGoodtrials ] = threshold_3dtrials(inmat3d, threshold)
% caluclate three metrics of data quality at the trial level

    absvalvec = squeeze(mean(max(abs(inmat3d),[], 2'))); % mean range of voltage value for each trial
    
    badindex = find(absvalvec > threshold);
    
    inmat3d(:, :, badindex) = []; 

    figure(901), plot(absvalvec), yline(threshold);
    
    NGoodtrials = size(inmat3d,3);



