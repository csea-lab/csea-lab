%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LB3_findclusters_cbp: creates 4D volume
%%% function to find spatial and temporal clusters (of neighboring sensors) with permutated t-values
%%% exceeding a certain t-value threshold over time and frequency bins using bwconncomp
%%% bwconncomp finds connected components in binary image (requires signal processing toolbox)
%%% needs shrunk coordinates (cube_coords)
%%% --> prepare shrunk coordinates with prepcoord_4cluster.m
% can handle 3dim t-values (e.g., elec x timepoints x frequency bins)

%%%% INPUT:
%%% 1) t_values_in (t-values from permutation or original) - format: (number of electrodes x timepoints x frequency bins)
%%% 2) cube coordinates of sensor layout (channel positions) - shrunk 3D positions of all sensors, format (nr of sensors x 3)
%%%    format is: x,y,z (range between -1 and 1) from EEGTemp chanlocs
%%% 3) threshold (t-value threshold) - single value
%%% 4) teststat: 1=t-value (pos and neg), 2=F-Value (pos only)
%%% 5) nameflag (if electrodelabels should also be included in output), optional
%%% 6) timefreqflag (if timepoints and frequency bins should also be included in output), optional

%%%% OUTPUT:
%%% 1) cluster_out_pos and 2) cluster_out_neg as struct containing clustersize (timepoint and electrodes),
%%% names (names of sensors, 1st column, and their clusterindex in 2nd column, optional with nameflag)
%%% sum (sum of t values of each cluster), max_t value and min_t_value of
%%% the clusters, clusterdetails: timepoints and frequency bins of clusters with the number of the electrode (optional with timefreqflag)

% Version: 03.12.2024
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [cluster_out_pos, cluster_out_neg, BW1] = LB3_findclusters_cbp_4D(t_values_in, cube_coords, threshold, teststat, nameflag, timefreqflag)

% t_values_in=permute(t_values_in, [2 1 3]); % so that they have size: elec,tp,freqbin, e.g. 129x1000x13
n_freqbins = size(t_values_in,3);  % number of frequency bins

% 1. Make 4D volume
volumeWithTs = zeros(max(cube_coords(:, 1)), max(cube_coords(:, 2)), max(cube_coords(:, 3)), n_freqbins); % initialize

% For every freqbin, timepoint and sensor save t-value in volumeWithTs (5D)
for freqbin = 1:size(t_values_in,3)
    for timepoint = 1:size(t_values_in,2) % loop over time
        for elec = 1:size(t_values_in,1) % loop over sensors
            volumeWithTs(cube_coords(elec,1), cube_coords(elec,2), cube_coords(elec,3), timepoint, freqbin) = squeeze(t_values_in(elec,timepoint,freqbin));
        end
    end
end

% 2. Keep electrode labels to map clusters back to original sensor labels
volume_names = (zeros(size(volumeWithTs, [1:3,5]))); % initialize
for freqbin=1:n_freqbins  % loop over frequency bins
    for elec = 1:size(t_values_in,1) % loop over sensors
        volume_names(cube_coords(elec,1), cube_coords(elec,2), cube_coords(elec,3), freqbin) = elec;
    end
end
size_x = size(volume_names,1);
size_y = size(volume_names,2);
size_z = size(volume_names,3);
freq = size(volume_names,4);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% here for t-values
if teststat ==1 % t-value --> pos and neg cluster

    % 3. Finding the clusters from 4-D data by binarizing 2D image or 3D volume by thresholding
    % loops over 4th dimension because it can't do 4-D binarization
    BW1 = []; % initialize positive
    BW2 = []; % initialize negative
    for freqbin = 1:n_freqbins
        for timepoint2 = 1:size(volumeWithTs,4) % for every timepoint
            BW1(:, :, :, freqbin, timepoint2) = imbinarize(squeeze(volumeWithTs(:, :, :, timepoint2, freqbin)), threshold); % binarize volume (positive)
            BW2(:, :, :, freqbin, timepoint2) = imbinarize(squeeze(volumeWithTs(:, :, :, timepoint2, freqbin)).*-1, threshold); % binarize volume (negative)
        end
    end

    % 4. Calc CON with bwconncomp: finds connected components in BW (can also do 5D input)
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
        clustersize1(clusterindex) = sum(sum(sum(sum(sum(labelmat1 == clusterindex)))));
        clusterSums1(clusterindex) = sum(mat2vec(volumeWithTs(labelmat1 == clusterindex)));
        var1 = squeeze(sum(sum(sum(labelmat1 == clusterindex))));  % this is of size freqbin x tp
        varsum_freq1(:,clusterindex) = sum(var1,2); % freqs
        varsum_time1(clusterindex,:) = sum(var1,1); % tp
    end

    % get clustersize and clustersums - CON2 (neg)
    labelmat2 = labelmatrix(CON2); % assigns labels to the clusters, 1 for first, 2 forsecond, and so on
    clustersize2 = zeros(1, CON2.NumObjects); % initialize a vector
    clusterSums2 = zeros(1, CON2.NumObjects); % initialize a vector
    for clusterindex = 1:CON2.NumObjects % number of clusters found
        clustersize2(clusterindex) = sum(sum(sum(sum(sum(labelmat2 == clusterindex)))));
        clusterSums2(clusterindex) = sum(mat2vec(volumeWithTs(labelmat2 == clusterindex)));
        var2 = squeeze(sum(sum(sum(labelmat2 == clusterindex))));  % this is of size freqbin x tp
        varsum_freq2(:,clusterindex) = sum(var2,2); % freqs
        varsum_time2(clusterindex,:) = sum(var2,1); % tp
    end

    if timefreqflag % if timefreqflag was an argument, then give out all the details with timepoints of when cluster starts and ends and the freqbins
        clusterdetails_pos = {};
        headers={'clusterindex', 'frequency bin', 'starting tp', 'cluster end tp', 'exact tps', 'channels'};
        clusterdetails_pos(1,:)=headers;
        for clusterindex = 1:CON1.NumObjects % number of clusters found
            ftemp = varsum_freq1(:,clusterindex) ~=0;
            freqbins = find(ftemp==1);
            ttemp = varsum_time1(clusterindex,:) ~=0;
            tpts = find(ttemp==1);
            tpfirst = find(ttemp,1,"first");
            tplast = find(ttemp,1,"last");
            clusterdetails_pos(clusterindex+1,1) = {clusterindex};
            clusterdetails_pos(clusterindex+1,2) = {freqbins};
            clusterdetails_pos(clusterindex+1,3) = {tpfirst};
            clusterdetails_pos(clusterindex+1,4) = {tplast};
            clusterdetails_pos(clusterindex+1,5) = {tpts};
        end

        clusterdetails_neg = {};  % same for neg clusters
        headers={'clusterindex', 'frequency bin', 'starting tp', 'cluster end tp', 'exact tps', 'channels'};
        clusterdetails_neg(1,:)=headers;
        for clusterindex = 1:CON2.NumObjects % number of clusters found
            ftemp = varsum_freq2(:,clusterindex) ~=0;
            freqbins = find(ftemp==1);
            ttemp = varsum_time2(clusterindex,:) ~=0;
            tpts = find(ttemp==1);
            tpfirst = find(ttemp,1,"first");
            tplast = find(ttemp,1,"last");
            clusterdetails_neg(clusterindex+1,1) = {clusterindex};
            clusterdetails_neg(clusterindex+1,2) = {freqbins};
            clusterdetails_neg(clusterindex+1,3) = {tpfirst};
            clusterdetails_neg(clusterindex+1,4) = {tplast};
            clusterdetails_neg(clusterindex+1,5) = {tpts};
        end

    else
        clusterdetails_pos = {};
        clusterdetails_neg = {};
    end % timefreqflag


    %  Get labels of electrodes if needed (which electrodes are part of cluster?)
    namevol = zeros(size(volume_names));  % zb 9x10x9
    clusternames1 = [];
    if nameflag
        for f=1:n_freqbins
            for x = 1:size_x
                for y = 1:size_y
                    for z = 1:size_z
                        if any(labelmat1(x,y,z,f,:))
                            temp = unique(squeeze(labelmat1(x,y,z,f, squeeze(labelmat1(x,y,z,f,:)) ~=0)));  %%%
                            % labelmat is 5D, fifth is time:
                            % 10x11x11x13x1000
                            for j=1:length(temp)
                                a=unique((squeeze(labelmat1(x,y,z,f, squeeze(labelmat1(x,y,z,f,:)) ==temp(j)))));
                                %if namevol(x,y,z)>0
                                % volume_names(x,y,z)
                                % namevol(x,y,z)
                                % clusternames = [clusternames; volume_names(x,y,z), namevol(x,y,z)];
                                clusternames1 = [clusternames1; volume_names(x,y,z,f), a];
                            end

                        end

                    end % z
                end % y
            end % x
        end  % freqbins
        for clusterindex = 1:CON1.NumObjects % number of clusters found
            tempvar = clusterindex==clusternames1(:,2);
            namesidx= find(tempvar==1);
            elecstemp = clusternames1(namesidx,1);
            elecs_of_cluster = unique(elecstemp);
            clusterdetails_pos{clusterindex+1,6}=elecs_of_cluster;
        end
    else
        clusternames1 = [];
    end

    clusternames2 = [];
    if nameflag
        for f=1:n_freqbins
            for x = 1:size_x
                for y = 1:size_y
                    for z = 1:size_z
                        if any(labelmat2(x,y,z,f,:))
                            % namevol(x,y,z) = nanmean(squeeze(labelmat(x,y,z, squeeze(labelmat(x,y,z, :)) ~=0)));  %%%
                            temp = unique(squeeze(labelmat2(x,y,z,f, squeeze(labelmat2(x,y,z,f,:)) ~=0)));  %%%
                            for j=1:length(temp)
                                %namevol(x,y,z) = labelmat(squeeze(labelmat(x,y,z, :)==temp(j)));  %%%
                                %namevol(x,y,z) = squeeze(labelmat(x,y,z, squeeze(labelmat(x,y,z, :)) ==temp(j)),:);  %%%
                                a=unique((squeeze(labelmat2(x,y,z,f, squeeze(labelmat2(x,y,z,f,:)) ==temp(j)))));
                                %if namevol(x,y,z)>0
                                % volume_names(x,y,z)
                                % namevol(x,y,z)
                                % clusternames = [clusternames; volume_names(x,y,z), namevol(x,y,z)];
                                clusternames2 = [clusternames2; volume_names(x,y,z,f), a];
                            end
                        end % if
                    end % z
                end % y
            end % x
        end % freqbins
        for clusterindex = 1:CON2.NumObjects % number of clusters found
            tempvar = clusterindex==clusternames2(:,2);
            namesidx= find(tempvar==1);
            elecstemp = clusternames2(namesidx,1);
            elecs_of_cluster = unique(elecstemp);
            clusterdetails_neg{clusterindex+1,6}=elecs_of_cluster;
        end
    else
        clusternames2 = [];
    end

    % 6. Prep output in cluster_out_pos (structure):
    cluster_out_pos = struct(...
        'size', [],...
        'names', [], ...
        'sum', [],...
        'max_t',[],...
        'min_t',[],...
        'details',[]);
    cluster_out_pos.size = clustersize1;
    cluster_out_pos.sum = clusterSums1;
    cluster_out_pos.names = clusternames1;  % clusternames is elec and their clusterindex
    cluster_out_pos.max_t=max(clusterSums1);
    cluster_out_pos.min_t=min(clusterSums1);
    cluster_out_pos.details=clusterdetails_pos;


    % 7. Prep output in cluster_out_neg (structure):
    cluster_out_neg = struct(...
        'size', [],...
        'names', [], ...
        'sum', [],...
        'max_t',[],...
        'min_t',[],...
        'details',[]);
    cluster_out_neg.size = clustersize2;
    cluster_out_neg.sum = clusterSums2;
    cluster_out_neg.names = clusternames2;
    cluster_out_neg.max_t=max(clusterSums2);
    cluster_out_neg.min_t=min(clusterSums2);
    cluster_out_neg.details=clusterdetails_neg;

end % if t-value

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% here for F-value

if teststat ==2 % F-value
    % 3. Finding the clusters from 4-D data by binarizing 2D image or 3D volume by thresholding
    % loops over 4th dimension because it can't do 4-D binarization
    BW1 = []; % initialize positive
    for freqbin = 1:n_freqbins
        for timepoint2 = 1:size(volumeWithTs,4) % for every timepoint
            BW1(:, :, :, freqbin, timepoint2) = imbinarize(squeeze(volumeWithTs(:, :, :, timepoint2, freqbin)), threshold); % binarize volume (positive)
        end
    end

    % 4. Calc CON with bwconncomp: finds connected components in BW (can also do 5D input)
    CON1 = bwconncomp(BW1); % CON1 is struct, pos cluster

    % get clustersize and clustersums - CON1 (pos)
    labelmat1 = labelmatrix(CON1); % assigns labels to the clusters, 1 for first, 2 forsecond, and so on
    clustersize1 = zeros(1, CON1.NumObjects); % initialize a vector
    clusterSums1 = zeros(1, CON1.NumObjects); % initialize a vector
    for clusterindex = 1:CON1.NumObjects % number of clusters found
        clustersize1(clusterindex) = sum(sum(sum(sum(sum(labelmat1 == clusterindex)))));
        clusterSums1(clusterindex) = sum(mat2vec(volumeWithTs(labelmat1 == clusterindex)));
        var1 = squeeze(sum(sum(sum(labelmat1 == clusterindex))));  % this is of size freqbin x tp
        varsum_freq1(:,clusterindex) = sum(var1,2); % freqs
        varsum_time1(clusterindex,:) = sum(var1,1); % tp
    end

    % Get labels of electrodes if needed (which electrodes are part of cluster?)
    namevol = zeros(size(volume_names));  % zb 9x10x9
    clusternames1 = [];
    if nameflag
        for f=1:n_freqbins
            for x = 1:size_x
                for y = 1:size_y
                    for z = 1:size_z
                        if any(labelmat1(x,y,z,f,:))
                            temp = unique(squeeze(labelmat1(x,y,z,f, squeeze(labelmat1(x,y,z,f,:)) ~=0)));  %%%
                            % labelmat is 5D, fifth is time:
                            % 10x11x11x13x1000
                            for j=1:length(temp)
                                a=unique((squeeze(labelmat1(x,y,z,f, squeeze(labelmat1(x,y,z,f,:)) ==temp(j)))));
                                clusternames1 = [clusternames1; volume_names(x,y,z,f), a];
                            end
                        end
                    end % z
                end % y
            end % x
        end % freqbin

        for clusterindex = 1:CON1.NumObjects % number of clusters found
            tempvar = clusterindex==clusternames1(:,2);
            namesidx= find(tempvar==1);
            elecstemp = clusternames1(namesidx,1);
            elecs_of_cluster = unique(elecstemp);
            clusterdetails_pos{clusterindex+1,6}=elecs_of_cluster;
        end
    else
        clusternames1 = [];
    end

    % 6. Prep output in cluster_out_pos (structure):
    cluster_out_pos = struct(...
        'size', [],...
        'names', [], ...
        'sum', [],...
        'max_t',[],...
        'min_t',[]),...
        'details',[];

    cluster_out_pos.size = clustersize1;
    cluster_out_pos.sum = clusterSums1;
    cluster_out_pos.names = clusternames1;  % clusternames is elec and their clusterindex
    cluster_out_pos.max_t=max(clusterSums1);
    cluster_out_pos.min_t=min(clusterSums1);
    cluster_out_pos.details=clusterdetails_pos;

    cluster_out_neg = [];  % stays empty, just pos. clusters when F-test

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