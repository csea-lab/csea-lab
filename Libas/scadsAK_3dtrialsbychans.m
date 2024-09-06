function [ outmat3d, badindexmat] = scadsAK_3dtrialsbychans(inmat3d, threshold, EcfgFilePath)
% caluclate three metrics of data quality at the trial level

badindexmat = []; 
outmat3d = zeros(size(inmat3d)); 

    for trial = 1:size(inmat3d,3)

        qualindex = []; 
        
        trialdata2d = squeeze(inmat3d(:, :, trial)); 
         
             % calculate three metrics of data quality at the channel level    
            absvalvec = median(abs(trialdata2d)')./ max(median(abs(trialdata2d)')); % Median absolute voltage value for each channel
            stdvalvec = std(trialdata2d')./ max(std(trialdata2d')); % SD of voltage values
            maxtransvalvec = max(diff(trialdata2d'))./ max(max(diff(trialdata2d'))); % Max diff (??) of voltage values
               
            % calculate compound quality index
            qualindex = absvalvec+ stdvalvec+ maxtransvalvec; 

             % calculate std for the 95% distribution
            cutoff = quantile(qualindex, .95);
            actualdistribution = qualindex(qualindex < cutoff); 
            
            % find the bad channels
             BadChanVec =  find(qualindex > median(qualindex) + (threshold).* std(actualdistribution));

             badindexmat{trial} = BadChanVec; 

            trialdata2d_interp = Scads2dSplineInterpChan(trialdata2d, BadChanVec, EcfgFilePath, .2);
    
        outmat3d(:, :, trial) = trialdata2d_interp; % Creates output file where bad channels have been replaced with interpolated data

    end % trial


   
 


