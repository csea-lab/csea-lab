function [data_out] =SCADS_AK(data, locations); 
% takes continuous chan by time data, makes random segments of 1000 sample
% points, checks bad channels
% interpolates bad channels and returns continuous data

interpsensvec = []; 

data = data(1:32,:); 

data = regressionMAT(data);

data_out = data; 

[a1,b1] = size(data); 

% create 3d mat, to see if a channel is consistently bad

dimsize3 = floor(b1/1000); 

inmat3d = reshape(data(:, 1:dimsize3*1000), 32, 1000, dimsize3);

elocsXYZ= zeros(size(locations,2),3); % Creates an empty variable for cartesian coordinates & corresponding data

% find X, Y, Z for each sensor
    for elec = 1:a1
        
       elocsXYZ(elec,1) =  locations((elec)).X;
       elocsXYZ(elec,2) =  locations((elec)).Y;
       elocsXYZ(elec,3) =  locations((elec)).Z;
    end
       
% first, identify bad channels

    for trial = 1:size(inmat3d,3)
    
    trialdata2d = inmat3d(:, :, trial); 
    
    % caluclate three metrics of data quality at the channel level
    
    absvalvec = median(abs(trialdata2d)')./ max(median(abs(trialdata2d)')); % Median absolute voltage value for each channel
    stdvalvec = std(trialdata2d')./ max(std(trialdata2d')); % SD of voltage values
    maxtransvalvec = max(diff(trialdata2d'))./ max(max(diff(trialdata2d'))); % Max diff (??) of voltage values
    
   
    % calculate compound quality index
    qualindex = absvalvec+ stdvalvec+ maxtransvalvec; 
    figure
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
   
    end
    
    chancounts = hist(interpsensvec, 1:32); figure(101), hist(interpsensvec, 1:32); pause(.5), figure(1)
    
    disp('badsensors')
    
    badsensors = find(chancounts>dimsize3./3)
       
    % set bad data channels nan, so that they are not used for inerpolating each other  
       
    cleandata = data_out; 
    cleandata(badsensors,:) = nan;  
    
    % interpolate those channels from 6 nearest neighbors in the cleandata
    % find nearest neighbors
    
    for badsensor = 1:length(interpvec)
       
        for elec2 = 1:size(data_out,1); 
            
            interpvec(badsensor)
            
            distvec(elec2) = sqrt((elocsXYZ(elec2,1)-elocsXYZ(interpvec(badsensor),1)).^2 + (elocsXYZ(elec2,2)-elocsXYZ(interpvec(badsensor),2)).^2 + (elocsXYZ(elec2,3)-elocsXYZ(interpvec(badsensor),3)).^2);
        
        end
    
           [dist, index]= sort(distvec); 
           
           size( cleandata(interpvec(badsensor),:)); size(mean(cleandata(index(2:7), :),1));                 
           
           data_out(interpvec(badsensor),:) = nanmean(cleandata(index(2:4), :),1); 
           
           plot(nanmean(cleandata(index(2:4), :),1))
          
    
    end    

   

