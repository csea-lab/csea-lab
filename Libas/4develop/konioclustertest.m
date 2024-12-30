
cd '/Users/andreaskeil/Desktop/Konioproject 2024/hampfiles'
clear

coor3d = ReadSfpFile('GSN-HydroCel-129.sfp');
coor3d(129,:) = [0 0 8.899];
no_elec = size(coor3d,1);

 [cube_coords,r] = LB3_prepcoord_4clusters(coor3d);

elecvecexclude = [128 127];

filemat = getfilesindir(pwd, '*hamp8');

distribMAX = []; 
distribMIN = []; 

filemat21 = filemat(1:4:end,:);
filemat22 = filemat(2:4:end,:);
filemat23 = filemat(3:4:end,:);
filemat24 = filemat(4:4:end,:);

%[topo_tmat, mat3d_1, mat3d_2] = topottest(filemat22, filemat21, [], 'ttest22vs21');
[topo_tmat, mat3d_1, mat3d_2] = topottest(filemat24, filemat23, [], 'ttest24vs23', 1);

datmat4d = cat(4,mat3d_1, mat3d_2);

for loop = 1:1000

     datmat4d_perm = datmat4d; 

    for sub= 1:50

        datmat4d_perm(:, :, sub,1:2) =  datmat4d(:, :, sub,randperm(2));

    end

        [~, ~, ~, stats] = ttest(squeeze(datmat4d_perm(:, :, :, 2)), squeeze(datmat4d_perm(:, :, :, 1)), 'Dim',3);

        stats.tstat(elecvecexclude,:) = 0; 

        [cluster_out_pos_perm, cluster_out_neg_perm] = LB3_findclusters_cbp_3D(stats.tstat, cube_coords, 2.06, 1, 0, 0);

        if ~isempty(cluster_out_pos_perm.sum)
             distribMAX(loop) = max(cluster_out_pos_perm.sum); 
        else 
            distribMAX(loop) =0;
        end
        
        if ~isempty(cluster_out_neg_perm.sum)
              distribMIN(loop) = min(cluster_out_neg_perm.sum); 
        else
            distribMIN(loop) = 0;
        end

        if round(loop./100) == loop/100, fprintf('.'), end

end








