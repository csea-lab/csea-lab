%% Input EEGlab .set file (for a specific condition). Identifies and replaces bad channels for each trial. Output is 3-D matrix.
% To run this script alone, must load dataset into EEGLab, then use following command before running this function: 
% inmat3d = ALLEEG.data; 
function [outmat2d, interpvec] = scadsAK_2dInterpChan(inmat2d, locations)

% find XYZ from eeglab format locations matrix in workspace (2nd argin),
% put in 3d matrix elocsXYZ

 for elec = 1:size(inmat2d, 1);      
       elocsXYZ(elec,1) =  locations((elec)).X;
       elocsXYZ(elec,2) =  locations((elec)).Y;
       elocsXYZ(elec,3) =  locations((elec)).Z;
 end

% first, identify bad channels across all epochs 

    trialdata2d = inmat2d; 
    
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
    
         % set bad data channels nan, so that they are not used for inerpolating each other  
        cleandata = trialdata2d; 
        cleandata(interpvec,:) = nan; 
    
   outmat2d = inmat2d; 
        
    for badsensor = 1:length(interpvec)
       
        for elec2 = 1:size(inmat2d,1); 
            distvec(elec2) = sqrt((elocsXYZ(elec2,1)-elocsXYZ(interpvec(badsensor),1)).^2 + (elocsXYZ(elec2,2)-elocsXYZ(interpvec(badsensor),2)).^2 + (elocsXYZ(elec2,3)-elocsXYZ(interpvec(badsensor),3)).^2);
        end
    
           [dist, index]= sort(distvec); 
           
           size( trialdata2d(interpvec(badsensor),:)); size(mean(trialdata2d(index(2:7), :),1));                 
           
           trialdata2d(interpvec(badsensor),:) = nanmean(cleandata(index(2:12), :),1); 
           
           outmat2d = trialdata2d; % Creates output file where bad channels have been replaced with interpolated data
    
    end  
    
interpvec = interpvec;

