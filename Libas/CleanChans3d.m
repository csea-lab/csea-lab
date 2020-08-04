%% Input EEGlab .set file (for a specific condition). Identifies and replaces bad channels for each trial. Output is 3-D matrix.
% To run this script alone, must load dataset into EEGLab, then use following command before running this function: 
% inmat3d = ALLEEG.data; 
function [outmat3d, interpsensvec] = CleanChans3d(inmat3d, elocsXYZ); 


interpsensvec = []; 

outmat3d = inmat3d; % Creates a new matrix the same size as the input matrix

% first, identify bad channels

    for trial = 1:size(inmat3d,3)
    
    trialdata2d = inmat3d(:, :, trial); 
    
    % caluclate three metrics of data quality at the channel level
    
    absvalvec = median(abs(trialdata2d)'); % Median absolute voltage value for each channel
    stdvalvec = std(trialdata2d'); % SD of voltage values
    maxtransvalvec = max(diff(trialdata2d')); % Max diff (??) of voltage values
    
    % calculate compound quality index
    qualindex = absvalvec+ stdvalvec+ maxtransvalvec; 
    
    % detect indices of bad channels; currently anything farther than 3 SD
    % from the median quality index value %% TO DO - GET OUTPUT OF WHICH
    % CHANNELS ARE BAD FOR EACH TRIAL
   interpvec =  find(qualindex > median(qualindex) + 3.* std(qualindex));
   
   % append channels that are bad so that we have them after going through
   % the trials
   
   interpsensvec = [interpsensvec interpvec];
    
    
    % set bad data channels nan, so that they are not used for inerpolating each other  
    cleandata = trialdata2d; 
    cleandata(interpvec,:) = nan; 
    
    % interpolate those channels from 6 nearest neighbors in the cleandata
    % find nearest neighbors
    
    for badsensor = 1:length(interpvec)
       
        for elec2 = 1:size(inmat3d,1); 
            distvec(elec2) = sqrt((elocsXYZ(elec2,1)-elocsXYZ(interpvec(badsensor),1)).^2 + (elocsXYZ(elec2,2)-elocsXYZ(interpvec(badsensor),2)).^2 + (elocsXYZ(elec2,3)-elocsXYZ(interpvec(badsensor),3)).^2);
        end
    
           [dist, index]= sort(distvec); 
           
           size( trialdata2d(interpvec(badsensor),:)); size(mean(trialdata2d(index(2:7), :),1));
           
           trialdata2d(interpvec(badsensor),:) = nanmean(cleandata(index(2:4), :),1); 
           
           outmat3d(:, :, trial) = trialdata2d; % Creates output file where bad channels have been replaced with interpolated data
    
    end    

    end
interpsensvec = unique(interpsensvec) 