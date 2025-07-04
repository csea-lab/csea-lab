%% GaborGen Tone post processing code - Clean

%% SSVEP RESS Method
% Set working directory to the RESS data folder
clear
clc
%cd /Users/csea/Documents/SarahLab/Sarah_Data/GaborgenTone/Data/pipeline/data-600/'New Folder'/;
 cd /Users/andreaskeil/Desktop/gaborgentone


% Get trial files for RESS analysis
 filemat = getfilesindir(pwd, 'gaborgentone*trls*.pow3.mat'); %don't need to use this now; want original files, not Pow

% Loop over subjects to compute RESS spatial filters for each group of 4 conditions.
for filestart = 1:4:88
    filemat_actual = filemat(filestart:filestart+3, :);
    pause(1)
    RESS_filegroups23(filemat_actual, 1:120, 301:1300, 500, 15, 0);
end


% Merge RESS power files across conditions
filemat = getfilesindir(pwd, 'gabor*RESSpow*');
mergemulticons(filemat, 4, 'GM22.RESSpow');

% cd /Users/csea/Documents/SarahLab/Sarah_Data/GaborgenTone/Data/pipeline/data-600/spectra/RESS
% Load merged condition files for plotting/statistics
csplus = ReadAvgFile('GM22.RESSpow1.at');
GS1 = ReadAvgFile('GM22.RESSpow2.at');
GS2 = ReadAvgFile('GM22.RESSpow3.at');
GS3 = ReadAvgFile('GM22.RESSpow4.at');

% Build a 4D matrix for statistics: channels x frequencies x subjects x conditions
[repmatress] = makerepmat(filemat, 22, 4, []);
% load repmatress.mat;

% Perform an F test (ANOVA-like contrast) on RESS power over frequency
for frequency = 1:500
    temprep = squeeze(repmatress(:, frequency, :, :));
    repmatress2 = reshape(temprep, [1, 22, 4]);
    [Fcontmat_linear_ress(:, frequency),~,~,~,~] = contrast_rep_sign(repmatress2, [-2 -1 1 2]);
end

% SaveAvgFile('Fcontmat_linear_ress.at',Fcontmat_linear_ress,[],[],2000)


faxisFFT = 0:.5:250; 

figure
plot(faxisFFT(5:100), csplus(5:100), 'r', LineWidth=2), hold on, 
plot(faxisFFT(5:100), GS1(5:100), 'm'), 
plot(faxisFFT(5:100), GS2(5:100), 'b'), 
plot(faxisFFT(5:100), GS3(5:100), 'g'), 
bar(faxisFFT(5:100), GS3(5:100), 'k')
title 'RESS Spectra by Condition', fontsize = 22, legend 

% extract the power at 15 Hz for an anova-like spreadsheet thing 
filemat = getfilesindir(pwd, '*RESSpow.at')
[outmat] = extractstats(filemat, 4, 1, 31, []);
bar(faxisFFT(5:100), GS3(5:100), 'k')

% we saved the stat matrix to a file called resspower4cons.csv; sarah saved
% as ress_gaborgentone.csv

%% RESS Linear effect Bayesian Bootstrapping and Permutation
% uses the repmatress
clear
clc
cd /Users/csea/Documents/SarahLab/Sarah_Data/GaborgenTone/Data/pipeline/data-600/spectra/RESS
load repmatress.mat;
linearBootstrap =[];
size(repmatress)
nsubjects = size(repmatress, 3); 
% make distributions of effects
lineareffect = [-2 -1 1 2]; 

% the linear effect distribution
for elec = 1:size(repmatress,1)
        for  frequency = 1:size(repmatress,2)
            for draw = 1:2000
            bootstrapvec = randi(nsubjects, 1,nsubjects)';
            linearBootstrap(elec, frequency, draw) = mean(squeeze(repmatress(elec, frequency, bootstrapvec, : )), 1) * lineareffect';
            end
        end
end
%
% the null distribution permutation
linearBootstrapPerm = []
elec = 1;
for perm = 1:2000
    repeatmatperm_Ress = repmatress;
    for subject = 1:nsubjects
           repeatmatperm_Ress(: , :, subject, 1:4) = repmatress(: , :, subject, randperm(4));

    end
    for  frequency = 1:size(repmatress,2)
          
            bootstrapvec = randi(nsubjects, 1,nsubjects)';
            linearBootstrapPerm(elec, frequency, perm) = mean(squeeze(repeatmatperm_Ress(elec, frequency, bootstrapvec, : )), 1) * lineareffect';
           
    end
    disp(['draw ', num2str(perm)])
end


% Compare the bootstrapped with permuted data
for elec = 1:size(repmatress,1)
    for frequency = 1:size(repmatress,2)
     
            BFmap_RESS_linear(elec, frequency) = bootstrap2BF_z(squeeze(linearBootstrap(elec, frequency, :)),squeeze(linearBootstrapPerm(elec, frequency, :)), 0);
      
    end
end

faxisFFT = 0:.5:250;
faxisFFT(31) 
plot(BFmap_RESS_linear)
title 'Bayes Factors Linear RESS' 

%% RESS Selective effect Bayesian Bootstrapping and Permutation
clear
clc

load repmatress.mat; % 1 electrode, 500 freqs, 22 people, 4 conds

% uses the repmatress
selectBootstrap_csplus =[];
size(repmatress)
nsubjects = size(repmatress, 3); 

% make distributions of effects
selecteffect = [3 -1 -1 -1]; 


% the linear effect distribution
for elec = 1:size(repmatress,1)
        for  frequency = 1:size(repmatress,2)
            for draw = 1:2000
            bootstrapvec = randi(nsubjects, 1,nsubjects)';
            selectBootstrap_csplus(elec, frequency, draw) = mean(squeeze(repmatress(elec, frequency, bootstrapvec, : )), 1) * selecteffect';
            end
        end
end


% the null distribution permutation
selectBootstrapPerm_csplus = []
elec = 1;
for perm = 1:2000
    repeatmatperm_Ress = repmatress;
    for subject = 1:nsubjects
           repeatmatperm_Ress(: , :, subject, 1:4) = repmatress(: , :, subject, randperm(4));
    end
    for  frequency = 1:size(repmatress,2)
          
            bootstrapvec = randi(nsubjects, 1,nsubjects)';
            selectBootstrapPerm_csplus(elec, frequency, perm) = mean(squeeze(repeatmatperm_Ress(elec, frequency, bootstrapvec, : )), 1) * selecteffect';
           
    end
    disp(['draw ', num2str(perm)])
end


% Compare the bootstrapped with permuted data
for elec = 1:size(repmatress,1)
    for frequency = 1:size(repmatress,2)
     
            BFmap_RESS_select_cs(elec, frequency) = bootstrap2BF_z(squeeze(selectBootstrap_csplus(elec, frequency, :)),squeeze(selectBootstrapPerm_csplus(elec, frequency, :)), 0);
      
    end
end

faxisFFT = 0:.5:250;
faxisFFT(31) %15 hz

figure, plot(BFmap_RESS_select_cs)

%see no effect; small Bayes Factors close to 1 (smaller means more support
%for null in this case)


%% RESS Selective effect ("CS-" response) Bayesian Bootstrapping and Permutation
clear
clc

load repmatress.mat;
% uses the repmatress
selectBootstrap_csminus =[];
size(repmatress)
nsubjects = size(repmatress, 3); 

% make distributions of effects
selecteffect = [-1 -1 -1 3]; 


% the linear effect distribution
for elec = 1:size(repmatress,1)
        for  frequency = 1:size(repmatress,2)
            for draw = 1:2000
            bootstrapvec = randi(nsubjects, 1,nsubjects)';
            selectBootstrap_csminus(elec, frequency, draw) = mean(squeeze(repmatress(elec, frequency, bootstrapvec, : )), 1) * selecteffect';
            end
        end
end


% the null distribution permutation
selectBootstrapPerm_csplus = []
elec = 1;
for perm = 1:2000
    repeatmatperm_Ress = repmatress;
    for subject = 1:nsubjects
           repeatmatperm_Ress(: , :, subject, 1:4) = repmatress(: , :, subject, randperm(4));
    end

    for  frequency = 1:size(repmatress,2)      
            bootstrapvec = randi(nsubjects, 1,nsubjects)';
            selectBootstrapPerm_csminus(elec, frequency, perm) = mean(squeeze(repeatmatperm_Ress(elec, frequency, bootstrapvec, : )), 1) * selecteffect';
           
    end
    disp(['draw ', num2str(perm)])
end


% Compare the bootstrapped with permuted data
for elec = 1:size(repmatress,1)
    for frequency = 1:size(repmatress,2)
     
            BFmap_RESS_select_csminus(elec, frequency) = bootstrap2BF_z(squeeze(selectBootstrap_csminus(elec, frequency, :)),squeeze(selectBootstrapPerm_csminus(elec, frequency, :)), 0);
      
    end
end

faxisFFT = 0:.5:250;
faxisFFT(31) %15 hz

figure, plot(BFmap_RESS_select_csminus)

%see no effect; small Bayes Factors close to 1 (smaller means more support
%for null in this case)



%% SSVEP Single-Trial Spectra Method
clear
clc
% power from the FFT3d (normal FFT, no RESS) is an aletrnative to the RESS, we examine this next:
cd /Users/csea/Documents/SarahLab/Sarah_Data/GaborgenTone/Data/pipeline/data-600/'New Folder'/;

% does spectral analysis on each single trial and then
% averages them together within conditions) which gives combo of steady state response from each
% single trial and also all spontaneous (noise) frequencies will be
% retained bc they are not attenuated by any type of averaging; (each trial
% may be in different phase but phase information is not used)

%only want original trls files (not PLI or POW)
filemat = getfilesindir(pwd, 'gabor*trls*.mat'); %dont need to do this now
% Compute FFT on each trial (using the desired time window and frequency resolution)
get_FFT_mat3d(filemat, 301:1300, 500);

% Get FFT spectrum files ('.spec') and merge across conditions
cd /Users/csea/Documents/SarahLab/Sarah_Data/GaborgenTone/Data/pipeline/data-600/spectra/Spec;

filemat = getfilesindir(pwd, '*.spec');
mergemulticons(filemat, 4, 'GM22.singletrialspec');

 [outmat] = extractstats(filemat, 4, [70 71 74 75 76 82 83] , 31, []);

% we saved the stat matrix to a file called resspower4cons.csv

% to further examine this with method with higher sensitivity, we examined the largest effect visible post-hoc
% Build repmat for statistical analysis: sensors x frequencies x subjects x conditions
[repmatsingleSpec] = makerepmat(filemat, 22, 4, []);

[Fcontmat,rcontmat,MScont,MScs, dfcs]=contrast_rep_sign(squeeze(repmat(:, 31, :, :)) ,[-1.5 -.5 .5 1.5]);

% now do the permutation test to see if this survives
for draw = 1:1000

    for x = 1:22
       repmat(:, :, x, 1:4) =  repmat(:, :,x, randperm(4));
    end

[Fcontmat,rcontmat,MScont,MScs, dfcs]=contrast_rep_sign(squeeze(repmat(:, 31, :, :)) ,[-1.5 -.5 .5 1.5]);

dist(draw) = max(Fcontmat); 

if draw./100 == round(draw./100), fprintf('.'), end

end
MPP_AK
hist(dist, 50)
quantile(dist, .95)

% Load merged condition files for plotting/statistics
csplus = ReadAvgFile('GM22.singletrialspec.at1');
GS1 = ReadAvgFile('GM22.singletrialspec.at2');
GS2 = ReadAvgFile('GM22.singletrialspec.at3');
GS3 = ReadAvgFile('GM22.singletrialspec.at4');


figure
plot(csplus(72, 1:50), 'r', LineWidth=2), hold on, 
plot(GS1(72, 1:50), 'm'), 
plot(GS2(72, 1:50), 'b'), 
plot(GS3(72, 1:50), 'g')
title 'Single Trial Spectra by Condition', fontsize = 22, legend 

% so  this did also not survive any testing, there is no difference in the
% ssVEP at all


%% Bayes bootstrapping for single-trial spectra
clear
clc
cd /Users/csea/Documents/SarahLab/Sarah_Data/GaborgenTone/Data/pipeline/data-600/spectra/Spec
% uses the repmatsingleSpec: 129 channels, 500 freqs, 22 people, 4 conds
load('repmatsingleSpec.mat')
linearBootstrap =[];
size(repmatsingleSpec)
nsubjects = size(repmatsingleSpec, 3);
% make distributions of effects
lineareffect = [2 1 -1 -2];


% the linear effect distribution
for elec = 1:size(repmatsingleSpec,1)
    for  frequency = 1:size(repmatsingleSpec,2)
        for draw = 1:2000
            bootstrapvec = randi(nsubjects, 1,nsubjects)';
            linearBootstrap(elec, frequency, draw) = mean(squeeze(repmatsingleSpec(elec, frequency, bootstrapvec, : )), 1) * lineareffect';
        end 
    end
end
%%
cd /Users/csea/Documents/SarahLab/Sarah_Data/GaborgenTone/Data/pipeline/data-600/spectra/Spec
load('linearBootstrap_singleSpec.mat')
%%
% the null distribution permutation
linearBootstrapPerm = [];

for perm = 1:2000
    repeatmatperm_singleSpec = repmatsingleSpec;
    for subject = 1:nsubjects
        repeatmatperm_singleSpec(: , :, subject, 1:4) = repmatsingleSpec(: , :, subject, randperm(4));
    end

    for elec = 1:size(repmatsingleSpec,1)
        for  frequency = 1:size(repmatsingleSpec,2)
            bootstrapvec = randi(nsubjects, 1,nsubjects)';
            linearBootstrapPerm(elec, frequency, perm) = mean(squeeze(repeatmatperm_singleSpec(elec, frequency, bootstrapvec, : )), 1) * lineareffect';

        end
    end
    disp(['draw ', num2str(perm)])

end

%%
load('single_Spec_linearBootPerm.mat')
%% Compare the bootstrapped with permuted data
for elec = 1:size(repmatsingleSpec,1)
    for  frequency = 1:size(repmatsingleSpec,2)
        BFmap_singleSpec_linear(elec, frequency) = bootstrap2BF_z(squeeze(linearBootstrap(elec, frequency, :)),squeeze(linearBootstrapPerm(elec, frequency, :)), 0);
    end
end

faxisFFT = 0:.5:250;
faxisFFT(31) %15 hz

figure, plot(BFmap_singleSpec_linear(:, 31)) %select frequency of interest for all channels (15 hz which is the 31st bin)


% use SaveAvgFile to create file to use in emegs for heads
AvgMat = BFmap_singleSpec_linear;
SaveAvgFile('BFmap_singleSpec_linear.at',AvgMat,[],[], 1,[],[],[],[],1)

%need to make heads for single trial spec; Ask Andreas for help with this
emegs2d







%%
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





%% Alpha Wavelet Analysis
% Set working directory (if not already)
%cd /Users/csea/Documents/SarahLab/Sarah_Data/GaborgenTone/Data/pipeline/data-600/'New Folder'/;
 cd /Users/andreaskeil/Desktop/gaborgentone/trial3dmats
% Define frequency and time axes for wavelet analysis
faxisall = 0:1000/3600:250;    % full frequency axis for wavelets
faxis = faxisall(11:4:110);      % frequency axis used for plotting
taxis = -598:2:3000;           % time axis in ms

% Run wavelet analysis on trial files (returns power, phase-locking index, etc.)
% filemat = getfilesindir(pwd, 'gabor*trls*');
% [WaPower, PLI, PLIdiff] = wavelet_app_matfiles(filemat, 500, 11, 110, 4, 200:300, []);

% Process power files and group by condition:
filematpow = getfilesindir(pwd, 'gabor*pow3.mat');
filematpow21 = filematpow(1:4:end, :);
filematpow22 = filematpow(2:4:end, :);
filematpow23 = filematpow(3:4:end, :);
filematpow24 = filematpow(4:4:end, :);

% Compute grand means for each condition (optionally save these)
% GM22pow3_21 = avgmats_mat(filematpow21, 'GM22.at21.pow3.mat');
% GM22pow3_22 = avgmats_mat(filematpow22, 'GM22.at22.pow3.mat');
% GM22pow3_23 = avgmats_mat(filematpow23, 'GM22.at23.pow3.mat');
% GM22pow3_24 = avgmats_mat(filematpow24, 'GM22.at24.pow3.mat');

%load grand means for each condition
GM22pow3_21 = importdata('GM22.at21.pow3.mat', 'avgmat');
GM22pow3_22 = importdata('GM22.at22.pow3.mat', 'avgmat');
GM22pow3_23 = importdata('GM22.at23.pow3.mat', 'avgmat');
GM22pow3_24 = importdata('GM22.at24.pow3.mat', 'avgmat');


% Plot contour plots for a selected sensor
sensor = 72;
figure
subplot(4,1,1), contourf(taxis, faxis, squeeze(GM22pow3_21(sensor,:,:))'), colorbar
subplot(4,1,2), contourf(taxis, faxis, squeeze(GM22pow3_22(sensor,:,:))'), colorbar
subplot(4,1,3), contourf(taxis, faxis, squeeze(GM22pow3_23(sensor,:,:))'), colorbar
subplot(4,1,4), contourf(taxis, faxis, squeeze(GM22pow3_24(sensor,:,:))'), colorbar
sgtitle('Average Power by Condition: Sensor 62')

% Baseline-correct the grand means (using baseline indices 125:240)
GM22pow3_21_bsl = bslcorrWAMat_percent(GM22pow3_21, 125:240);
GM22pow3_22_bsl = bslcorrWAMat_percent(GM22pow3_22, 125:240);
GM22pow3_23_bsl = bslcorrWAMat_percent(GM22pow3_23, 125:240);
GM22pow3_24_bsl = bslcorrWAMat_percent(GM22pow3_24, 125:240);

% Plot baseline-corrected contours
figure
subplot(4,1,1), contourf(taxis, faxis, squeeze(GM22pow3_21_bsl(sensor,:,:))'), colorbar
subplot(4,1,2), contourf(taxis, faxis, squeeze(GM22pow3_22_bsl(sensor,:,:))'), colorbar
subplot(4,1,3), contourf(taxis, faxis, squeeze(GM22pow3_23_bsl(sensor,:,:))'), colorbar
subplot(4,1,4), contourf(taxis, faxis, squeeze(GM22pow3_24_bsl(sensor,:,:))'), colorbar
sgtitle('Average Power by Condition: Sensor ')

%% we used ttest3d to easily obtain 4-D arrays
  [ttestmat21_22, ~, mat4d22] = ttest3d(filematpow21, filematpow22, 1, 75:225);
  [ttestmat21_23, ~, mat4d23] = ttest3d(filematpow21, filematpow23, 1,  75:225);
  [ttestmat21_24, mat4d21, mat4d24] = ttest3d(filematpow21, filematpow24, 1,  75:225);

% %load in 4-d arrays
% load('mat4d21_csplus.mat')
% load('mat4d22_gs1.mat')
% load('mat4d23_gs2.mat')
% load('mat4d24_gs3.mat')

 repeatmat_alpha = cat(5, mat4d21(:, 1:10:end, :, :), mat4d22(:, 1:10:end, :, :), mat4d23(:, 1:10:end, :, :), mat4d24(:, 1:10:end, :, :));

% F test across time for the alpha band (averaging across 25 frequencies)
for time = 1:180
    for frequency = 1:25
      [Fcontmat_linearWavelet(:, time, frequency),rcontmat,~,MScs, dfcs]=contrast_rep_sign(squeeze(repeatmat_alpha(:, time, frequency, :, :)),[-2 -1 1 2]); 
      [Fcontmat_CSselectWavelet(:, time, frequency),rcontmat,MScont,MScs, dfcs]=contrast_rep_sign(squeeze(repeatmat_alpha(:, time, frequency, :, :)),[-3 1 1 1]);   
    end
    if mod(time,100)==0, fprintf('.'); end
end

% Plot F-test results for alpha at selected sensors
figure
contourf(taxis(1:10:end), faxis, squeeze(Fcontmat_CSselectWavelet(72,:,:))'), colorbar
title('F tests for alpha - Sensor 72')

figure
plot(taxis(1:10:end), Fcontmat_CSselectWavelet(sensor,:,8))
title('F tests for alpha - Sensor 65')

% Decimate and average data for further alpha statistics
% first, we out the data into an array to have an easier time 
% to make this happen, we decimate the time dimension and the frequemcy
% dimension
mat4d4stats = squeeze(cat(5, mat4d21(:,1:10:1800,8,:), ...
                              mat4d22(:,1:10:1800,8,:), ...
                              mat4d23(:,1:10:1800,8,:), ...
                              mat4d24(:,1:10:1800,8,:)));

% from 550- to 1300 sample points is 500 post stimulus to 2000 ms post
% stimulus
% in decimated points that is 55 to 130
outmat4statsalpha = squeeze(mean(mean(mat4d4stats([75 62 55 81 72],55:130,:,:))));


%% do the bayesian bootstrap for Alpha Power
% uses the repeatmat
linearBootstrap =[];
size(repeatmat_alpha)
nsubjects = size(repeatmat_alpha, 4); 
% make distributions of effects
lineareffect = [3 -1 -1 -1];

% the linear effect distribution
for draw = 1:2000
    bootstrapvec = randi(nsubjects, 1,nsubjects)';

    for elec = 1:size(repeatmat_alpha,1)
        for timepoint = 1:size(repeatmat_alpha,2)
            for  frequency = 1:size(repeatmat_alpha,3)


                linearBootstrap(elec, timepoint, frequency, draw) = ...
                    mean(squeeze(repeatmat_alpha(elec, timepoint, frequency, bootstrapvec, : ))) * lineareffect';
            end
        end
    end
    if draw/100 == round(draw/100), disp(['draw:  ', num2str(draw)]), end
end
%%
% the null distribution permutation
linearBootstrapPerm = [];
for perm = 1:2000
    repeatmat_alphaperm = repeatmat_alpha;
    for subject = 1:nsubjects
        repeatmat_alphaperm(:, :, :, subject, :) = repeatmat_alphaperm(:, :, :, subject, randperm(4));
    end
    for elec = 1:size(repeatmat_alpha,1)
        for timepoint = 1:size(repeatmat_alpha,2)
            for  frequency = 1:size(repeatmat_alpha,3)
                bootstrapvec = randi(nsubjects, 1,nsubjects)';
                linearBootstrapPerm(elec, timepoint, frequency, perm) = mean(squeeze(repeatmat_alphaperm(elec,timepoint, frequency, bootstrapvec, : ))) * lineareffect';
            end
        end
    end
      if perm/100 == round(perm/100), disp(['perm ', num2str(perm)]), end
end

%% comparison between model and permuted values
% BFmap_alpha results in 129 channels x 180 timepoints x 25 frequencies
for elec = 1:size(repeatmat_alpha,1)
    for timepoint = 1:size(repeatmat_alpha,2) %180 timepoints, decimated earlier
        for  frequency = 1:size(repeatmat_alpha,3) %25 frequencies, decimated earlier (8th is alpha)
            BFmap_alpha(elec, timepoint, frequency) = bootstrap2BF_z(squeeze(linearBootstrap(elec,timepoint, frequency, :)),squeeze(linearBootstrapPerm(elec,timepoint, frequency, :)), 0);
        end
    end
    fprintf('.')
end

plot(BFmap_alpha(:,:,8)) %faxis shows alpha is now 8th in 3rd dimension
BFmap_alpha(129,25, 8)