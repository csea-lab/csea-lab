function [ inmat3d, badindex ] = scadsAK_3dtrialsECoG(inmat3d);
%
%    performs scads procedure on trials and gets rid of bad trials
%  replaces bad trials with white noise

% caluclate three metrics of data quality at the trial level
    
    absvalvec = squeeze(median(median(abs(inmat3d),2'))); % Median absolute voltage value for each trial
    % here on
    stdvalvec = squeeze(median(std(inmat3d,[],2))); % SD of voltage values
    
    maxtransvalvec = squeeze(median(max(diff(inmat3d, 2),[], 2))); % Max diff (??) of voltage values
    
    % calculate compound quality index and discard outlier trials
    qualindex = absvalvec+ stdvalvec+ maxtransvalvec;
    
    badindex = find(qualindex > 1.2.* median(qualindex))
    
    size(inmat3d)
    size(inmat3d(:, :, badindex) )
    size(rand(size(inmat3d,1),size(inmat3d,2), size(badindex,1)))
    
    inmat3d(:, :, badindex) = rand(size(rand(size(inmat3d,1),size(inmat3d,2), size(badindex,1)))); 
    
    % calculate remaining number of trials
    qualindex(qualindex > 1.2.* median(qualindex)) = [];
    
    NGoodtrials = length(qualindex)

end

