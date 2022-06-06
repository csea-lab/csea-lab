function [sumDist_mx,thresSum_mx,di_index,clusterSums_mx,clustIdx_mx,sumDist_mn,thresSum_mn,clusterSums_mn,clustIdx_mn] = ...
    cc_threshold(InMat,whichDataType,biFlag,thres,plotFlag,outName)
% determine contiguous cluster extent thresholds for MNE-EEG or fMRI data 
    % utility version, meaning it can do any stat and any type of data, not
    % specific to any one project
% follows methods similar to Maris, E., & Oostenveld, R. (2007). Nonparametric statistical testing of EEG-and MEG-data. Journal of neuroscience methods, 164(1), 177-190.
% =========================================================================
% inputs:
    % InMat = [spatial dimensions of data] x permuations, with stats from shuffled data (if determining thresholds) or real data (if finding clusters) 
        % if EEG data: dipoles, perms [currently only set to run on 350 dipoles]
        % if fMRI data: x, y, z, perms
    % whichData = 'eeg' or 'fmri' 
    % biFlag = if the threshold is bi-sided == true/1 (e.g., t-vals, correlation coefficients)
    % thres = threshold, IF BI-SIDED, ***MAX FIRST*** -> e.g., [5.5 -5.5]
    % plotFlag = IF you want to see the sum distribution historgam & quantile threshold
    % outName = IF you want to save the outmat, whatcha wanna name it?
        % if you don't want to save anything, exclude from command       
% outputs for DETERMINING THRESHOLDS:
    % sumDist_m@ = vectors; distribution for sums of clusters
        % write out and save to modify quantile-based thresholds
    % thresSum_m@ = single number; 95th quantile thresholds for sum of clusters, or 2.5 & 97.5th for bi-sided stats
    % di_index = vector; indexes location of each dipole in 3d space so you can find them in F vector
        % not necessary for fMRI data
        % best to do this with data x perms instead of real data, idk why 
% outputs for FINDING "significant" CLUSTERS:
    % clusterSums_m@ = vector; sum of each cluster that meets/exceeds threshold
    % clustIdx_m@ = cell vector; indexes each cluster in 3d space

% IF DETERMINING THRESHOLDS FROM *SHUFFLED* DATA ==> [sumDist_mx,thresSum_mx,di_index] = cluster_permUtil(F_perm,'eeg',0,3.055);
% IF FINDING CLUSTERS IN YOUR *REAL* DATA ==> [~,~,~,clusterSums_mx,clustIdx_mx] = cluster_permUtil(F_real,'eeg',0,3.055);
% ============================================================ MB, May 2022
size_mx = []; sumDist_mx = [];
size_mn = []; sumDist_mn = [];
% get data in proper format
    if strcmp(whichDataType, 'eeg')
        load locations_350.mat
        [~,~,rnk_1] = unique(round(locations_350(:, 1).*10));  % round to make ties of almost identical locations
        [~,~,rnk_2] = unique(round(locations_350(:, 2).*10));
        [~,~,rnk_3] = unique(locations_350(:, 3));
        for x = 1:350
            newInMat(rnk_1(x),rnk_2(x),rnk_3(x),:) = InMat(x,:); % fill with data from 350 places
            di_index(x) = find(newInMat(:,:,:,1) == InMat(x,1));
        end   
    elseif strcmp(whichDataType, 'fmri')
        newInMat = InMat;
    end
% do the thing, per iteration/permutation
    for iter = 1:size(newInMat,4)
        data = newInMat(:,:,:,iter);
        thres_mx = thres(1,1);
    % Find logical matrix where data > threshold
        biVec_mx = data > thres_mx; 
    % find contiguous dipoles/regions
        cc_mx = bwconncomp(biVec_mx);
        clustIdx_mx = cc_mx.PixelIdxList;
    % Measure lengths of each region and the indexes
        labelmat_mx = labelmatrix(cc_mx);   
    % get cluster size and sum
        clustersize_mx = zeros(1, cc_mx.NumObjects); 
        clusterSums_mx = zeros(1, cc_mx.NumObjects);
        for clusterindex = 1:cc_mx.NumObjects   
            clustersize_mx(clusterindex) = sum(sum(sum(labelmat_mx == clusterindex)));
            clusterSums_mx(clusterindex) = sum(mat2vec(data(labelmat_mx == clusterindex)));
        end
        size_mx = [size_mx max(clustersize_mx)];
        sumDist_mx = [sumDist_mx max(clusterSums_mx)];
    % if stat is bi-sided, do it for the minimum threshold too 
        if biFlag == true
            thres_mn = thres(1,2);        
            biVec_mn = data < thres_mn;
            cc_mn = bwconncomp(biVec_mn);
            clustIdx_mn = cc_mn.PixelIdxList;
            labelmat_mn = labelmatrix(cc_mn);
            clustersize_mn = zeros(1, cc_mn.NumObjects); 
            clusterSums_mn = zeros(1, cc_mn.NumObjects);
            for clusterindex = 1:cc_mn.NumObjects   
                clustersize_mn(clusterindex) = sum(sum(sum(labelmat_mn == clusterindex)));
                clusterSums_mn(clusterindex) = sum(mat2vec(data(labelmat_mn == clusterindex)));
            end
            size_mn = [size_mn max(clustersize_mn)];
            sumDist_mn = [sumDist_mn min(clusterSums_mn)];
        end % bisided flag
    if round(iter./200) == iter./200, fprintf('.'), end % progress indicator
    end % iteration
% get quantile thresholds
    thresSz_mx = max(quantile(size_mx, .95));
    thresSum_mx = max(quantile(sumDist_mx, .95)); 
    if biFlag == true
        thresSz_mn = max(quantile(size_mn, .95));
        thresSum_mx = max(quantile(sumDist_mx, .975));
        thresSum_mn = min(quantile(sumDist_mn, .025)); 
        if nargin > 5, save(outName,'sumDist_mx','sumDist_mn','thresSum_mn','thresSum_mx'), end
        if nargin > 4
            figure
            hist(sumDist_mn,50), hold on, hist(sumDist_mx,50)
            xlabel('stat sum')
            vertmarks([thresSum_mn thresSum_mx])
            title({'stat sum'; num2str([thresSum_mn thresSum_mx])})
        end
    else
        if nargin > 5, save(outName,'sumDist_mx','thresSum_mx'), end
        if nargin > 4
            figure
            hist(sumDist_mx,50)
            xlabel('stat sum')
            vertmark(thresSum_mx)
            title({'stat sum'; num2str(thresSum_mx)})
        end
    end % plots and saving
end % function 