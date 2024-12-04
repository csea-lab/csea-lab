%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LB3: prepare (shrink) layout coordinates
%%% function to prepare coordinates (3D) and "shrink" them into cubes so that these cubes as coordinates can be 
%%% later put into LB3_findclusters as input to run clusterbased permutation (based on BWconncomp)
%%%
%%% needs as input: 
% 1) sensor net/coordinates (XZY), e.g., sfp file
%%% output:
% 1) cube_coords (for LB3_findcluster)
% 2) outfactor r (shrinkage/growth)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [cube_coords,r] = LB3_prepcoord_4clusters(coor3d)

%% 1.) load in example layouts (e.g., with an sfp file)

%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    % VPT - BrainVision 26 channel
%     cd '/Users/125a/Desktop/MCP_Project/Data/VPT';
%     load VPTdata_4MCP.mat;
%     % load xyz coordinates
%     %coord = load('chanpos.mat')
%     coor3d = coord.chanpos;
 
    no_elec = size(coor3d,1);
    if norm(coor3d(1,:)) < 1.1
        coor3d = coor3d.*4;
    end


%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %% - 129 EGI
%     cd '/Users/125a/Desktop/MATLAB_files/fieldtrip-20240307/template/electrode'
%     coor3d = ReadSfpFile('GSN-HydroCel-129.sfp');
%     % 128 elecs, ref electrode Cz is missing --> open as txt file to see where Cz should be
%     % add ref
%     coor3d(129,:) = [0 0 8.899];
%     no_elec = size(coor3d,1);
%     if norm(coor3d(1,:)) < 1.1
%         coor3d = coor3d.*4;
%     end

%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %% - 256 EGI
%     cd '/Users/125a/Desktop/MATLAB_files/fieldtrip-20240307/template/electrode'
%     coor3d = ReadSfpFile('GSN-HydroCel-256.sfp');
%     % etwa zwischen -9 und +10
%     % Ref electrode Cz missing --> open as txt file to see where Cz should be
%     coor3d(257,:) = [0 0 9.68];
%     if norm(coor3d(1,:)) < 1.1
%         coor3d = coor3d.*4;
%     end
%     no_elec = size(coor3d,1);
%     if norm(coor3d(1,:)) < 1.1
%         coor3d = coor3d.*4;
%     end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %% AK Version
    % give all elecs a value that exceeds threshold (all is one)

    faket_vals_ak = rand(no_elec,1);
    faket_vals_ak(1:end) = 5;

    a=0; % for while loop
    index=1; % start index

    while a==0
        r = index/10;
        shrink3d_1 = round(coor3d./r); % shrunk coordinates in original space (which was zero-centered)
        cube_coords = shrink3d_1+abs(min(min(shrink3d_1)))+1; % now in absolute, positive coordinates that can be used as indices

        [cluster_out_pos,cluster_out_neg, BW] = LB3_findclusters_cbp(faket_vals_ak, cube_coords, 4, 1,1);
        if  size(cluster_out_pos.no,2) ==1 % when only one cluster is found
            a=1; % stop
            % r is shrinkage factor, cube coords are shrunken coordinates
        else
            index = index +.2;  % else shrink more
        end
    end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %  plot3(cube_coords(:,1), cube_coords(:,2), cube_coords(:,3), 'o')

end % function

