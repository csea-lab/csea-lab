% postprocessing4sarah

%% first do the wavelet analysis

cd /Users/andreaskeil/Desktop/gaborgentone/trial3dmats/

filemat = getfilesindir(pwd, '*trls*');

faxisall = 0:1000/3600:250;
faxis = faxisall(11:4:110);
taxis = -598:2:3000;

[WaPower, PLI, PLIdiff] = wavelet_app_matfiles(filemat, 500, 11, 110, 4, 200:300, []); 

filematpow = getfilesindir(pwd, '*pow3.mat'); 

% make the grand means by condition
filematpow21 = filematpow(1:4:end,:);
filematpow22 = filematpow(2:4:end,:);
filematpow23 = filematpow(3:4:end,:);
filematpow24 = filematpow(4:4:end,:);

GM22pow3_21 = avgmats_mat(filematpow21, 'GM22.at21.pow3.mat');
GM22pow3_22 = avgmats_mat(filematpow22, 'GM22.at22.pow3.mat');
GM22pow3_23 = avgmats_mat(filematpow23, 'GM22.at23.pow3.mat');
GM22pow3_24 = avgmats_mat(filematpow24, 'GM22.at24.pow3.mat');

% contourf commands
sensor = 81;
figure, 
subplot(4,1,1), contourf(taxis, faxis, squeeze(GM22pow3_21(sensor,:, :))'), colorbar
subplot(4,1,2), contourf(taxis, faxis, squeeze(GM22pow3_22(sensor,:, :))'), colorbar
subplot(4,1,3), contourf(taxis, faxis, squeeze(GM22pow3_23(sensor,:, :))'), colorbar
subplot(4,1,4), contourf(taxis, faxis, squeeze(GM22pow3_24(sensor,:, :))'), colorbar

% paired ttests
[ttestmat21_22, ~, mat4d22] = ttest3d(filematpow21, filematpow22, 1, 125:240);
[ttestmat21_23, ~, mat4d23 ] = ttest3d(filematpow21, filematpow23, 1, 125:240);
[ttestmat21_24, mat4d21, mat4d24] = ttest3d(filematpow21, filematpow24, 1, 125:240);

% baseline
GM22pow3_21_bsl = bslcorrWAMat_percent(GM22pow3_21, 125:240); 
GM22pow3_22_bsl = bslcorrWAMat_percent(GM22pow3_22, 125:240); 
GM22pow3_23_bsl = bslcorrWAMat_percent(GM22pow3_23, 125:240); 
GM22pow3_24_bsl = bslcorrWAMat_percent(GM22pow3_24, 125:240); 

% contourf commands for baseline
figure, 
subplot(4,1,1), contourf(taxis, faxis, squeeze(GM22pow3_21_bsl(sensor,:, :))'), colorbar
subplot(4,1,2), contourf(taxis, faxis, squeeze(GM22pow3_22_bsl(sensor,:, :))'), colorbar
subplot(4,1,3), contourf(taxis, faxis, squeeze(GM22pow3_23_bsl(sensor,:, :))'), colorbar
subplot(4,1,4), contourf(taxis, faxis, squeeze(GM22pow3_24_bsl(sensor,:, :))'), colorbar

% conduct ttests, pairwise
[ttestmat21_22, ~, mat4d22] = ttest3d(filematpow21, filematpow22, 1, []); 
[ttestmat21_23, ~, mat4d23 ] = ttest3d(filematpow21, filematpow23, 1, []); 
[ttestmat21_24, mat4d21, mat4d24] = ttest3d(filematpow21, filematpow24, 1, []); 

% alpha is the 8th frequency in the faxis
alphatopottests21_22 = squeeze(ttestmat21_22(:, :, 8)); 
alphatopottests21_23 = squeeze(ttestmat21_23(:, :, 8)); 
alphatopottests21_24 = squeeze(ttestmat21_24(:, :, 8)); 

% save alpha ttest files
SaveAvgFile('alphatopottests21_22.at',alphatopottests21_22,[],[],500)
SaveAvgFile('alphatopottests21_23.at',alphatopottests21_23,[],[],500)
SaveAvgFile('alphatopottests21_24.at',alphatopottests21_24,[],[],500)


%% ttests are stupid, let's do the F test
for time = 1:1800
    for frequency = 1:25

    repeatmat = cat(3, squeeze(mat4d21(:, time, frequency, :)), squeeze(mat4d22(:, time, frequency, :)), ...
        squeeze(mat4d23(:, time, frequency, :)), squeeze(mat4d24(:, time, frequency, :))); 

    [Fcontmat_linear(:,time, frequency),rcontmat,MScont,MScs, dfcs]=contrast_rep_sign(repeatmat,[-2 -1 1 2]); 
    
    end
    if time./100 == round(time./100), fprintf('.'), end
end
%% plot the result
contourf(taxis, faxis, squeeze(Fcontmat_linear(sensor,:, :))'), colorbar
% save the alpha stuff as at file 
alphatFtests = squeeze(Fcontmat_linear(:, :, 8)); 

plot(taxis, Fcontmat_linear(81, :, 8))

%% spectra for the ssvep
% the first method

filemat = getfilesindir(pwd, '*trls*');

get_FFT_mat3d(filemat, 301:1300, 500);

filemat = getfilesindir(pwd, '*.spec');

mergemulticons(filemat, 4, 'GM22.singletrialspec')

% do the F test
 [repmat] = makerepmat(filemat, 22, 4, []);

for frequency = 1:500
    [Fcontmat_linear(:,frequency),rcontmat,MScont,MScs, dfcs]=contrast_rep_sign(squeeze(repmat(:, frequency, :, :)),[-2 -1 1 2]); 
end

SaveAvgFile('Fcontmat_linear_spec3d.at',Fcontmat_linear,[],[],2000)


%% the RESS is the second method
filemat = getfilesindir(pwd, '*trls*');

for filestart = 1:4:88
    filemat_actual = filemat(filestart:filestart+3, :); pause(1)
    RESS_filegroups23(filemat_actual, 1:120, 301:1300, 500, 15, 0) ;
end

filemat = getfilesindir(pwd, '*RESSpow*');
mergemulticons(filemat, 4, 'GM22.RESSpow')

con1 = ReadAvgFile('GM22.RESSpow.at1');
con2 = ReadAvgFile('GM22.RESSpow.at2');
con3 = ReadAvgFile('GM22.RESSpow.at3');
con4 = ReadAvgFile('GM22.RESSpow.at4');

 [repmatress] = makerepmat(filemat, 22, 4, []);

for frequency = 1:500
   temprep =  squeeze(repmatress(:, frequency, :, :)); 
   repmatress2 = reshape(temprep, [1 22 4]);
    [Fcontmat_linear_ress(:,frequency),rcontmat,MScont,MScs, dfcs]=contrast_rep_sign(repmatress2,[-2 -1 1 2]); 
end


SaveAvgFile('Fcontmat_linear_ress.at',Fcontmat_linear_ress,[],[],2000)

%% this cell is for the cluster based stuff

% first, make the coordinates for the cube
coor3d = ReadSfpFile('GSN-HydroCel-129.sfp');
coor3d(129,:) = [0 0 8.899];

if norm(coor3d(1,:)) < 1.1
    coor3d = coor3d.*4;
end
[cube_coords,r] = LB3_prepcoord_4clusters(coor3d);

% now run the cluster finding algorithm for the F test on the spec 3 D 
% (not RESS) 

frequency = 31; 

cd /Users/andreaskeil/Desktop/gaborgentone/spec3D
Fcontmatsigned = ReadAvgFile('Fcontmat_linear_spec3d.at');
threshold = 3.08; % fpdf(3.08, 1, 21); 
Fmat4test = Fcontmatsigned(:, frequency);
[cluster_out_pos_spec, cluster_out_neg_spec] = LB3_findclusters_cbp_3D(Fmat4test, cube_coords, threshold, 1, 1, 1);

% now do the actual permutation
filemat = getfilesindir(pwd, '*.spec');
[repmat] = makerepmat(filemat, 22, 4, []);


distpos = []; 
distneg = []; 

for draw = 1:5000
    repmat_perm = repmat; 
    for subject = 1:22
        repmat_perm(:, :, subject, :) = repmat(:, :, subject, randperm(4)); 
    end
    [Fcontmat_linear_perm,rcontmat,MScont,MScs, dfcs]=contrast_rep_sign(squeeze(repmat_perm(:, frequency, :, :)),[-2 -1 1 2]); 
    [cluster_out_pos_spec_perm, cluster_out_neg_spec_perm] = LB3_findclusters_cbp_3D(Fcontmat_linear_perm, cube_coords, threshold, 1, 0, 0);
   
    if ~isempty(cluster_out_pos_spec_perm.sum)
    distpos(draw) = max(cluster_out_pos_spec_perm.sum); 
    end
    
    if ~isempty(cluster_out_neg_spec_perm.sum)
    distneg(draw) = min(cluster_out_neg_spec_perm.sum); 
    end

    if draw./100 == round(draw./100), fprintf('.'), end

end


