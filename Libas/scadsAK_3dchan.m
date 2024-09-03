%% Input EEGlab .set file (for a specific condition). Identifies and replaces bad channels for each trial. Output is 3-D matrix.
% To run this script alone, must load dataset into EEGLab, then use following command before running this function:
% inmat3d = ALLEEG.data;
function [outmat3d, BadChanVec] = scadsAK_3dchan(inmat3d,  EcfgFilePath)

outmat3d = inmat3d; % Creates a new matrix the same size as the input matrix

[a1, dummy, dummy] = size(outmat3d);

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

   BadChanVec =  find(qualindex > median(qualindex) + 3.* std(actualdistribution));

    % interpolate those channels from 6 nearest neighbors in the cleandata
    % find nearest neighbors

    for trial = 1:size(inmat3d,3)

        trialdata2d = squeeze(inmat3d(:, :, trial));

        trialdata2d_interp = Scads2dSplineInterpChan(trialdata2d, BadChanVec, EcfgFilePath, .2);

        outmat3d(:, :, trial) = trialdata2d_interp; % Creates output file where bad channels have been replaced with interpolated data

    end % trial
