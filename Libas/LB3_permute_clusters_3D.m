%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LB3: permute clusters - 3D
%%% function to permute clusters to get the clusterthreshold in order to
%%% define "significant" clusters (i.e., exceeding the threshold) 
%%% (cluster defined based on BWconncomp) from LB3_findclusters
%
%%% input: 
% 1) no_draws: how many draws to get permutation distribution (e.g, 1000)
% 2) cube_coords (cube coordinates from prepcoord_4cluster, XYZ) (e.g. 26x3)
% 3) mat1t, mat2 (condition matrices) (tp x elecs x subj)
% 4) threshold (e.g., t-value)
% 5) teststat (1=t-test, 2= F-test)
% 6) percentage (e.g., .95)
%
%%% output:
% 1) clusterthreshold
% 2) clustersize: clustersize of respective cluster (timepoints and elecs)
% 3) number of clusters (how many)
% 4) max_t_values (size: 1 x no_draws)
% 5) min_t_values (size: 1 x no_draws)

% Version: 15.08.2024
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [clusterthreshold_pos, clusterthreshold_neg, clustersize_pos, clustersize_neg, no_of_clusters, max_t_values, min_t_values] = LB3_permute_clusters_3D(no_draws, cube_coords, mat1t, mat2t, threshold, teststat, percentage)

% mat1t --> cond 1
% mat2t --> cond2 --> each (tp, elec, subj)

    %%% run permutation and find actual cluster perm with perm. data
    mat4permt = cat(4, mat1t, mat2t); % size 4D: tp, elec, subj, 2)
    no_vpn = size(mat1t,3);
    max_t_values = [];
    min_t_values = [];

    for draw = 1:no_draws  
        for subj = 1:no_vpn
            mat_permed_t(:, :, subj,:) = mat4permt(:, :, subj, randperm(2));
        end

        % mat_permed_t needs to be of size: 
        % calc t-value
        [~, ~, ~, stats] = ttest(squeeze(mat_permed_t(:, :, :, 1)), squeeze(mat_permed_t(:, :, :, 2)), 'dim', 3);
        t_values_in = stats.tstat; % tp x elec
        t_values_in=t_values_in';   % flip for LB_findclusters_cbp
        
         % this runs through LB3_findclusters_cbp (no_draws) times and finds clusters in time & space
        [cluster_out_pos, cluster_out_neg] = LB3_findclusters_cbp_3D(t_values_in, cube_coords, threshold, teststat, 1,1);

        % if no cluster is found (empty), then enter 0? oder leave empty??
        % also for negative clusters?
        if isempty(cluster_out_pos.max_t)
            cluster_out_pos.max_t = 0;  
            cluster_out_pos.min_t = 0;  
        end

        if isempty(cluster_out_neg.max_t)
            cluster_out_neg.max_t = 0;
            cluster_out_neg.min_t = 0;
        end

        max_t_values=[max_t_values, cluster_out_pos.max_t];  % save max t-values and
        min_t_values=[min_t_values, cluster_out_neg.min_t]; %  min t-values

        if isempty(cluster_out_pos.no)
            no_of_clusters(draw)= 0;
        else
            a=size(cluster_out_pos.no);
            no_of_clusters(draw)=a(2);          
        end
        

        if isempty(cluster_out_pos.no)
            clustersize_pos(draw)= 0;
        else
            clustersize_pos(draw)=sum(cluster_out_pos.no);          
        end
       
        if isempty(cluster_out_neg.no)
            clustersize_neg(draw)= 0;
        else
            clustersize_neg(draw)=sum(cluster_out_neg.no);          
        end
       

        if round(draw./100) == draw./100, fprintf('.'), end % make progress dots
        % max_t_values gives you maximum t-value of sum of clusters

    end % draw

    % hist(max_t_values,50)
    % hist(min_t_values,50)

    % quantiles for threshold
    clusterthreshold_pos = quantile(max_t_values,percentage);
    clusterthreshold_neg = quantile(min_t_values,(1-percentage));

end % function


