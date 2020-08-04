%% Input EEGlab .set file (for a specific condition). Identifies and replaces bad channels for each trial. Output is 3-D matrix.
% To run this script alone, must load dataset into EEGLab, then use following command before running this function: 
% inmat3d = ALLEEG.data; 
function [outmat3d] = replacezerochan(inmat3d); 

outmat3d = inmat3d; % Creates a new matrix the same size as the input matrix

[a1, dummy, dummy] = size(outmat3d); 

% first, identify zero channels across all epochs 

    trialdata2d = reshape(inmat3d, size(inmat3d,1), size(inmat3d,2)*size(inmat3d,3));
    
    zerochanInds = find(mean(trialdata2d') ==0)
    
    % good channels
    goodchanInds = find(~ismember([1:27], zerochanInds))
      
    % interpolate those channels from the full channel set, for each trial
    
    if ~isempty(zerochanInds)
        
            for trial = 1:size(inmat3d,3)

                trialdata2d = inmat3d(:, :, trial); 
                
                replacedata_mean = mean(trialdata2d(goodchanInds,:)); 
                
                replacedata = repmat(replacedata_mean, length(zerochanInds), 1);

                trialdata2d(zerochanInds,:) = replacedata;

                outmat3d(:, :, trial) = trialdata2d; % Creates output file where bad channels have been replaced with interpolated data

            end
            
    end
    
