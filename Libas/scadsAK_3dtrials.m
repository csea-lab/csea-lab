function [ inmat3d, badindex, NGoodtrials ] = scadsAK_3dtrials(inmat3d)
% caluclate three metrics of data quality at the trial level

    absvalvec = squeeze(median(median(abs(inmat3d),2'))); % Median absolute voltage value for each trial

    stdvalvec = squeeze(median(std(inmat3d,[],2))); % SD of voltage values
    
    maxtransvalvec = squeeze(median(max(diff(inmat3d, 2),[], 2))); % Max diff of voltage values
    
    % calculate compound quality index and discard outlier trials
    qualindex = absvalvec./max(absvalvec)+ stdvalvec./max(stdvalvec)+ maxtransvalvec./max(maxtransvalvec); 
    
     cutoff = quantile(qualindex, .95)
     
     actualdistribution = qualindex(qualindex < cutoff) 
     
     plot(qualindex), yline(1.5.* median(actualdistribution))
    
    badindex = find(qualindex > 1.5.* median(actualdistribution));
    
    inmat3d(:, :, badindex) = []; 
    
    % calculate remaining number of trials
    qualindex(qualindex > 1.5.* median(qualindex)) = [];
    
    NGoodtrials = size(inmat3d,3)



