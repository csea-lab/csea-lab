
cd '/Users/andreaskeil/Desktop/Konioproject 2024/hampfiles'
clear

filemat = getfilesindir(pwd, '*hamp8');

filemat21 = filemat(1:4:end,:);
filemat22 = filemat(2:4:end,:);
filemat23 = filemat(3:4:end,:);         
filemat24 = filemat(4:4:end,:);

% luminance stimuli
% use topottest function to make 3d arrays: elec by time point by subject
[~, mat3d_1, mat3d_2] = topottest(filemat22, filemat21, [], [], 0);

BFmap_lumi = nan(size(mat3d_1,1), size(mat3d_1,2));

[effect_dist_bootstrap, nullperm_dist_bootstrap] = bootstrap_diffs(mat3d_1,mat3d_2);

for elec = 1:size(mat3d_1,1)
    for timepoint = 1:size(mat3d_1,2)
        BFmap_lumi(elec, timepoint) = bootstrap2BF_z(squeeze(effect_dist_bootstrap(elec,timepoint,:)),squeeze(nullperm_dist_bootstrap(elec,timepoint,:)), 0);
    end
   disp('elec: '), fprintf(num2str(elec))
end


% konio stimuli
% use topottest function to make 3d arrays: elec by time point by subject

[~, mat3d_1, mat3d_2] = topottest(filemat24, filemat23, [], [], 0);

BFmap_konio = nan(size(mat3d_1,1), size(mat3d_1,2));

[effect_dist_bootstrap, nullperm_dist_bootstrap] = bootstrap_diffs(mat3d_1,mat3d_2);

for elec = 1:size(mat3d_1,1)
    for timepoint = 1:size(mat3d_1,2)
        BFmap_konio(elec, timepoint) = bootstrap2BF_z(squeeze(effect_dist_bootstrap(elec,timepoint,:)),squeeze(nullperm_dist_bootstrap(elec,timepoint,:)), 0);
    end
    disp('elec: '), fprintf(num2str(elec))
end

% BFmap_konio and BFmap_Lumi converted to log10

BFmap_lumiLog10 = log10(BFmap_lumi);

BFmap_konioLog10 = log10(BFmap_konio);

SaveAvgFile('BFmap_lumiLog10.at', BFmap_lumiLog10, [], [], 500, [], [], [], [], 301);

SaveAvgFile('BFmap_konioLog10.at', BFmap_konioLog10, [], [], 500, [], [], [], [], 301);








