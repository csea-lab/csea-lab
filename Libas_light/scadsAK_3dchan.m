%% Input EEGlab .set file (for a specific condition). Identifies and replaces bad channels for each trial. Output is 3-D matrix.
% To run this script alone, must load dataset into EEGLab, then use following command before running this function: 
% inmat3d = ALLEEG.data; 
function [outmat3d, interpsensvec] = scadsAK_3dchan(inmat3d, locations); 


interpsensvec = []; 

outmat3d = inmat3d; % Creates a new matrix the same size as the input matrix

[a1, dummy, dummy] = size(outmat3d); 

% find XYZ from eeglab format locations matrix in workspace (2nd argin),
% put in 3d matrix elocsXYZ

 for elec = 1:a1      
       elocsXYZ(elec,1) =  locations((elec)).X;
       elocsXYZ(elec,2) =  locations((elec)).Y;
       elocsXYZ(elec,3) =  locations((elec)).Z;
    end

% first, identify bad channels across all epochs 

    trialdata2d = reshape(inmat3d, size(inmat3d,1), size(inmat3d,2)*size(inmat3d,3));
    
    % caluclate three metrics of data quality at the channel level
    
    absvalvec = median(abs(trialdata2d)')./ max(median(abs(trialdata2d)')); % Median absolute voltage value for each channel
    stdvalvec = std(trialdata2d')./ max(std(trialdata2d')); % SD of voltage values
    maxtransvalvec = max(diff(trialdata2d'))./ max(max(diff(trialdata2d'))); % Max diff (??) of voltage values
    
   
    % calculate compound quality index
    qualindex = absvalvec+ stdvalvec+ maxtransvalvec; 
    figure(101)
    plot(qualindex)
    
    
    % calculate std for the 95% distribution
    
    cutoff = quantile(qualindex, .95);
    
    actualdistribution = qualindex(qualindex < cutoff); 
    
     
    % detect indices of bad channels; currently anything farther than 3 SD
    % from the median quality index value 
         
    
   interpvec =  find(qualindex > median(qualindex) + 3.* std(actualdistribution));
   
   % append channels that are bad so that we have them after going through
   % the trials
   
   interpsensvec = [interpsensvec interpvec];
    
     
    % interpolate those channels from 6 nearest neighbors in the cleandata
    % find nearest neighbors
    
    for trial = 1:size(inmat3d,3)
        
        trialdata2d = inmat3d(:, :, trial); 
        
         % set bad data channels nan, so that they are not used for inerpolating each other  
        cleandata = trialdata2d; 
        cleandata(interpvec,:) = nan; 
    
    
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