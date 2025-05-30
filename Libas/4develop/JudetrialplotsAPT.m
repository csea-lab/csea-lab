% this is the single trial visualization script
clear 
cd '/Users/andreaskeil/Desktop/JudeGaborgen'

filemat = getfilesindir(pwd, '*win.mat');

% do all conditions at once, that is 12 conditions

startfileindex = 1:12:size(filemat,1);

% first habituation
    
    for subject = 1:length(startfileindex)
    
            for condition = 1:4
        
                file2load = filemat(startfileindex(subject)+condition-1, :);
        
                load(file2load)
        
                tempdata  = outmat.fftamp;
        
                data4Habituation(subject, condition,1:31,1:size(tempdata,2)) = tempdata;
        
            end   
    
    end

% now acquistion
 
    for subject = 1:length(startfileindex)
        
            for condition = 1:4
        
                file2load = filemat(startfileindex(subject)+condition+4-1, :); 
        
                load(file2load)
        
                tempdata  = outmat.fftamp;
        
                data4Acquisition(subject, condition, 1:31, 1:size(tempdata,2)) = tempdata;
        
            end   
    
    end

    % now extinction
 
    for subject = 1:length(startfileindex)
    
            for condition = 1:4
        
                file2load = filemat(startfileindex(subject)+condition+8-1, :);
        
                load(file2load)
        
                tempdata  = outmat.fftamp;
        
                data4Extinction(subject, condition, 1:31, 1:size(tempdata,2)) = tempdata;
        
            end   
    
    end

    data4allblocks = cat(4, data4Habituation, data4Acquisition, data4Extinction);

    data4allblocks_smooth = movmean(data4allblocks, 5, 4);

    testdat4plot = bslcorr(squeeze(mean(data4allblocks_smooth(:, :, 20, :))), 1:6);

    plot(testdat4plot')