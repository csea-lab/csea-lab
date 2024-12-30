%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LB3_findclusters_cbp
%%% function to find spatial and temporal clusters (of neighboring sensors) with permutated t-values
%%% exceeding a certain t-value threshold over time using bwconncomp
%%% bwconncomp finds connected components in binary image (signal processing toolbox)
%%% needs shrunk coordinates (cube_coords) 
%%% --> prepare shrunk coordinates with prepcoord_4cluster.m

%%%% INPUT:
%%% 1) t_values_in (t-values from permutation or original) - format (nr of sensors x timepoints)
%%% 2) cube coordinates of sensor layout (channel positions) - shrunk 3D positions of all sensors, format (nr of sensors x 3)
%%% format is: x,y,z (range between -1 and 1) from EEGTemp chanlocs
%%% 3) threshold (t-value threshold) - single value
%%% 4) teststat: 1=t-test (pos and neg), 2=F-Value (pos only)
%%% 5) nameflag (if electrodelabels should also be output), optional

%%%% OUTPUT:
%%% 1) cluster_out as struct containing number of clusters (no) and the clustersize (timepoint and electrodes), 
%%% names (names of sensors and their clusterindex, optional with nameflag)
%%% sum (sum of t values of each cluster), max_t value and min_t_value of the clusters

% Version: 15.08.2024

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [cluster_out_pos, cluster_out_neg, BW1] = LB3_findclusters_cbp(t_values_in, cube_coords, threshold, teststat, nameflag)

%%%%%% example data
%     t_values_in = rand(26,634);   % 26 elec, 634 tp
%     t_values_in([14,22], 100:150) = 4;  % cluster 1
%     t_values_in([1,2], 390:440) = 4;  % cluster 2
%     load('chanpos.mat')
%     coordinates = chanpos;  % chanpos (26x3)
%     threshold=3;

%%%%%%%%%%%%%%%%%%%%%%

% 1. Make 3D volume
volumeWithTs = zeros(max(cube_coords(:, 1)), max(cube_coords(:, 2)), max(cube_coords(:, 3))); % initialize

% For every timepoint and sensor save t-value in volumeWithTs
for timepoint = 1:size(t_values_in,2) % loop over time
    for elec = 1:size(t_values_in,1) % loop over sensors
        volumeWithTs(cube_coords(elec,1), cube_coords(elec,2), cube_coords(elec,3), timepoint) = t_values_in(elec,timepoint);
    end
end

% 2. Keep electrode labels to map clusters back to original sensor labels
volume_names = (zeros(size(volumeWithTs, 1:3))); % initialize
for elec = 1:size(t_values_in,1) % loop over sensors
    volume_names(cube_coords(elec,1), cube_coords(elec,2), cube_coords(elec,3)) = elec;
end
size_x = size(volume_names,1);
size_y = size(volume_names,2);
size_z = size(volume_names,3);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% here for t-values
if teststat ==1 % t-value --> pos and neg cluster

    % 3. Finding the clusters from 4-D data by binarizing 2D image or 3D volume by thresholding
    % loops over 4th dimension because it can't do 4-D binarization
    BW1 = []; % initialize positive
    BW2 = []; % initialize negative
    for timepoint2 = 1:size(volumeWithTs,4) % for every timepoint
        BW1(:, :, :, timepoint2) = imbinarize(volumeWithTs(:, :, :, timepoint2), threshold); % binarize volume (positive)
        BW2(:, :, :, timepoint2) = imbinarize(volumeWithTs(:, :, :, timepoint2).*-1, threshold); % binarize volume (negative)
    end

    % 4. Calc CON with bwconncomp: finds connected components in BW (4D input)
    CON1 = bwconncomp(BW1); % CON1 is struct, pos cluster
    CON2 = bwconncomp(BW2); % CON2 is struct, neg cluster
    % 8 is default connectivity (components connected when edges OR corners touch --> horizontal, vertical, diagonal)
    % can also be 4 (components connected when edges touch: horizontal, vertical)
    % default for 3D: 26

    % get clustersize and clustersums - CON1 (pos)
    labelmat1 = labelmatrix(CON1); % assigns labels to the clusters, 1 for first, 2 forsecond, and so on
    clustersize1 = zeros(1, CON1.NumObjects); % initialize a vector
    clusterSums1 = zeros(1, CON1.NumObjects); % initialize a vector
    for clusterindex = 1:CON1.NumObjects % number of clusters found
        clustersize1(clusterindex) = sum(sum(sum(sum(labelmat1 == clusterindex))));
        clusterSums1(clusterindex) = sum(mat2vec(volumeWithTs(labelmat1 == clusterindex)));
    end

    % get clustersize and clustersums - CON2 (neg)
    labelmat2 = labelmatrix(CON2); % assigns labels to the clusters, 1 for first, 2 forsecond, and so on
    clustersize2 = zeros(1, CON2.NumObjects); % initialize a vector
    clusterSums2 = zeros(1, CON2.NumObjects); % initialize a vector
    for clusterindex = 1:CON2.NumObjects % number of clusters found
        clustersize2(clusterindex) = sum(sum(sum(sum(labelmat2 == clusterindex))));
        clusterSums2(clusterindex) = sum(mat2vec(volumeWithTs(labelmat2 == clusterindex)));
    end


    % 5. Get labels of electrodes if needed (which electrodes are part of cluster?)
    namevol = zeros(size(volume_names));  % zb 9x10x9
    clusternames1 = [];

    if nameflag
        for x = 1:size_x
            for y = 1:size_y
                for z = 1:size_z
                    if any(labelmat1(x,y,z, :))
                        % namevol(x,y,z) = nanmean(squeeze(labelmat(x,y,z, squeeze(labelmat(x,y,z, :)) ~=0)));  %%%
                        temp = unique(squeeze(labelmat1(x,y,z, squeeze(labelmat1(x,y,z, :)) ~=0)));  %%%
                        for j=1:length(temp)
                            %namevol(x,y,z) = labelmat(squeeze(labelmat(x,y,z, :)==temp(j)));  %%%
                            %namevol(x,y,z) = squeeze(labelmat(x,y,z, squeeze(labelmat(x,y,z, :)) ==temp(j)),:);  %%%
                            a=unique((squeeze(labelmat1(x,y,z, squeeze(labelmat1(x,y,z, :)) ==temp(j)))));
                            %if namevol(x,y,z)>0
                            % volume_names(x,y,z)
                            % namevol(x,y,z)
                            % clusternames = [clusternames; volume_names(x,y,z), namevol(x,y,z)];
                            clusternames1 = [clusternames1; volume_names(x,y,z), a];

                        end
                    end

                end
            end
        end

    else
        clusternames1 = [];
    end

    clusternames2 = [];

    if nameflag
        for x = 1:size_x
            for y = 1:size_y
                for z = 1:size_z
                    if any(labelmat2(x,y,z, :))
                        % namevol(x,y,z) = nanmean(squeeze(labelmat(x,y,z, squeeze(labelmat(x,y,z, :)) ~=0)));  %%%
                        temp = unique(squeeze(labelmat2(x,y,z, squeeze(labelmat2(x,y,z, :)) ~=0)));  %%%
                        for j=1:length(temp)
                            %namevol(x,y,z) = labelmat(squeeze(labelmat(x,y,z, :)==temp(j)));  %%%
                            %namevol(x,y,z) = squeeze(labelmat(x,y,z, squeeze(labelmat(x,y,z, :)) ==temp(j)),:);  %%%
                            a=unique((squeeze(labelmat2(x,y,z, squeeze(labelmat2(x,y,z, :)) ==temp(j)))));
                            %if namevol(x,y,z)>0
                            % volume_names(x,y,z)
                            % namevol(x,y,z)
                            % clusternames = [clusternames; volume_names(x,y,z), namevol(x,y,z)];
                            clusternames2 = [clusternames2; volume_names(x,y,z), a];

                        end
                    end

                end
            end
        end

    else
        clusternames2 = [];
    end

    % 6. Prep output in cluster_out_pos (structure):
    cluster_out_pos = struct(...
        'no', [],...
        'names', [], ...
        'sum', [],...
        'max_t',[],...
        'min_t',[]);

    cluster_out_pos.no = clustersize1;
    cluster_out_pos.sum = clusterSums1;
    cluster_out_pos.names = clusternames1;
    cluster_out_pos.max_t=max(clusterSums1);
    cluster_out_pos.min_t=min(clusterSums1);


    % 7. Prep output in cluster_out_neg (structure):
    cluster_out_neg = struct(...
        'no', [],...
        'names', [], ...
        'sum', [],...
        'max_t',[],...
        'min_t',[]);

    cluster_out_neg.no = clustersize2;
    cluster_out_neg.sum = clusterSums2;
    cluster_out_neg.names = clusternames2;
    cluster_out_neg.max_t=max(clusterSums2);
    cluster_out_neg.min_t=min(clusterSums2);


end % if t-value


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% here for F-value

if teststat ==2 % F-value
    % 3. Finding the clusters from 4-D data by binarizing 2D image or 3D volume by thresholding
    % loops over 4th dimension because it can't do 4-D binarization
    BW1 = []; % initialize positive
    for timepoint2 = 1:size(volumeWithTs,4) % for every timepoint
        BW1(:, :, :, timepoint2) = imbinarize(volumeWithTs(:, :, :, timepoint2), threshold); % binarize volume
    end

    % 4. Calc CON with bwconncomp: finds connected components in BW (4D input)
    CON1 = bwconncomp(BW1); % CON is struct
    % 8 is default connectivity (components connected when edges OR corners touch --> horizontal, vertical, diagonal)
    % can also be 4 (components connected when edges touch: horizontal, vertical)
    % default for 3D: 26

    % get clustersize and clustersums
    labelmat = labelmatrix(CON1); % assigns labels to the clusters, 1 for first, 2 forsecond, and so on
    clustersize = zeros(1, CON1.NumObjects); % initialize a vector
    clusterSums = zeros(1, CON1.NumObjects); % initialize a vector
    for clusterindex = 1:CON1.NumObjects % number of clusters found
        clustersize(clusterindex) = sum(sum(sum(sum(labelmat == clusterindex))));
        clusterSums(clusterindex) = sum(mat2vec(volumeWithTs(labelmat == clusterindex)));
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % 5. Get labels of electrodes if needed (which electrodes are part of cluster?)
    namevol = zeros(size(volume_names));  % zb 9x10x9
    clusternames = [];

    if nameflag
        for x = 1:size_x
            for y = 1:size_y
                for z = 1:size_z
                    if any(labelmat(x,y,z, :))
                        % namevol(x,y,z) = nanmean(squeeze(labelmat(x,y,z, squeeze(labelmat(x,y,z, :)) ~=0)));  %%%
                        temp = unique(squeeze(labelmat(x,y,z, squeeze(labelmat(x,y,z, :)) ~=0)));  %%%
                        for j=1:length(temp)
                            %namevol(x,y,z) = labelmat(squeeze(labelmat(x,y,z, :)==temp(j)));  %%%
                            %namevol(x,y,z) = squeeze(labelmat(x,y,z, squeeze(labelmat(x,y,z, :)) ==temp(j)),:);  %%%
                            a=unique((squeeze(labelmat(x,y,z, squeeze(labelmat(x,y,z, :)) ==temp(j)))));
                            %if namevol(x,y,z)>0
                            % volume_names(x,y,z)
                            % namevol(x,y,z)
                            % clusternames = [clusternames; volume_names(x,y,z), namevol(x,y,z)];
                            clusternames = [clusternames; volume_names(x,y,z), a];

                        end
                    end

                end
            end
        end

    else
        clusternames = [];
    end

    % 6. Prep output in cluster_out (structure):
    cluster_out_pos = struct(...
        'no', [],...
        'names', [], ...
        'sum', [],...
        'max_t',[],...
        'min_t',[]);

    cluster_out_pos.no = clustersize;
    cluster_out_pos.sum = clusterSums;
    cluster_out_pos.names = clusternames;
    cluster_out_pos.max_t=max(clusterSums);
    cluster_out_pos.min_t=min(clusterSums);

    cluster_out_neg = [];

end  % if F-Value


end  % function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% Maris & Oostenveld, 2007:

% (1) For every sample,compare the signal on the two types of trials by means of a t-value (or some other number that quantifies the effect at this sample).
% (2) Select all samples whose t-value is larger than some threshold
% (This threshold may or may not be based on the sampling distribution of the t-value under the null hypothesis, but this does not affect the validity of the nonparametric test; see further.)
% (3) Cluster the selected samples in connected sets on the basis of temporal adjacency.
% (4) Calculate cluster-level statistics by taking the sum of the t-values within a cluster.
% (5) Take the largest of the cluster-level statistics.



