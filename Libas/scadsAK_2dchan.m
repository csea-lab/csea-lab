%% input is 2d-matric from fieldtrip. this function then calculates bad channels for continuous, unsegmented data
function [badindexvec] = scadsAK_2dchan(inmat,threshold)


    % caluclate three metrics of data quality at the channel level
    
    absvalvec = median(abs(inmat)')./ max(median(abs(inmat)')); % Median absolute voltage value for each channel
    stdvalvec = std(inmat')./ max(std(inmat')); % SD of voltage values
    maxtransvalvec = max(diff(inmat'))./ max(max(diff(inmat'))); % Max diff (??) of voltage values
    
   
    % calculate compound quality index
    qualindex = absvalvec+ stdvalvec+ maxtransvalvec; 
    figure(101)
    plot(qualindex)
    
    
    % calculate std for the 95% distribution
    
    cutoff = quantile(qualindex, .95);
    
    actualdistribution = qualindex(qualindex < cutoff); 
     
    % detect indices of bad channels; currently anything farther than 3 SD
    % from the median quality index value 
         
    
   badindexvec =  find(qualindex > median(qualindex) + (threshold).* std(actualdistribution));
   

    
 