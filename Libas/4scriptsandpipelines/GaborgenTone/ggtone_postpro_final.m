%% GaborGen Tone post-processing code - Final for repository

%% SSVEP RESS Method
% Set working directory to the RESS data folder
clear
clc
cd /Users/csea/Documents/SarahLab/Sarah_Data/GaborgenTone/Data/pipeline/data-600/'New Folder'/;
% cd /Users/andreaskeil/Desktop/gaborgentone

% Get trial files for RESS analysis
 filemat = getfilesindir(pwd, 'gaborgentone*trls*.pow3.mat'); %don't need to use this now; want original files, not Pow
% 
% Loop over subjects to compute RESS spatial filters for each group of 4 conditions.
for filestart = 1:4:88
    filemat_actual = filemat(filestart:filestart+3, :);
    pause(1)
    RESS_filegroups23(filemat_actual, 1:120, 301:1300, 500, 15, 0); %1000 sample points from baseline to sound onset = 2000 ms  
end

% Merge RESS power files across conditions
filemat = getfilesindir(pwd, 'gabor*RESSpow*');
mergemulticons(filemat, 4, 'GM22.RESSpow');


%% move ress grand mean files to spectra folder
cd /Users/csea/Documents/SarahLab/Sarah_Data/GaborgenTone/Data/pipeline/data-600/spectra/RESS
filemat = getfilesindir(pwd, 'gabor*RESSpow*');

% Load merged condition files for plotting/statistics
Csplus = ReadAvgFile('GM22.RESSpow.at1');
GS1 = ReadAvgFile('GM22.RESSpow.at2');
GS2 = ReadAvgFile('GM22.RESSpow.at3');
GS3 = ReadAvgFile('GM22.RESSpow.at4');

% Build a 4D matrix for statistics: channels x frequencies x subjects x conditions
[repmatress] = makerepmat(filemat, 22, 4, []);
load repmatress.mat;

% Perform an F test (ANOVA-like contrast) on RESS power over frequency
for frequency = 1:500
    temprep = squeeze(repmatress(:, frequency, :, :));
    repmatress2 = reshape(temprep, [1, 22, 4]);
    [Fcontmat_linear_ress(:, frequency),~,~,~,~] = contrast_rep_sign(repmatress2, [2 1 -1 -2]);
end

 SaveAvgFile('Fcontmat_linear_ress.at',Fcontmat_linear_ress,[],[],2000)
% Plot

faxisFFT = 0:.5:250; 


figure
plot(faxisFFT(1:40), Csplus(1:40), 'r', LineWidth=3), hold on, 
plot(faxisFFT(1:40), GS1(1:40), 'm', LineWidth=3), 
plot(faxisFFT(1:40), GS2(1:40), 'b', LineWidth=3), 
plot(faxisFFT(1:40), GS3(1:40), 'g', LineWidth=3), 
title 'RESS Spectra by Condition', fontsize = 22, legend 

%% open emegs and plot ssvep
emegs2d

%% extract the power at 15 Hz for an anova-like spreadsheet in jasp
filemat = getfilesindir(pwd, '*RESSpow.at')
[outmat] = extractstats(filemat, 4, 1, 31, []);
bar(faxisFFT(5:100), GS3(5:100), 'k')

% we saved the stat matrix to a file called resspower4cons.csv; 
% sarah saved as ress_gabortone.csv

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
lineareffect = [2 1 -1 -2]; 

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

BFmap_RESS_linear(31) %15 hz at 31st bin is BF of .304, not impressive

log10(BFmap_RESS_linear(31))


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
     
            BFmap_RESS_select_cs(elec, frequency) = bootstrap2BF_z(squeeze(selectBootstrap_csplus(elec, frequency, :)), ...
                squeeze(selectBootstrapPerm_csplus(elec, frequency, :)), 0);
      
    end
end

faxisFFT = 0:.5:250;
faxisFFT(31) %15 hz
figure, plot(BFmap_RESS_select_cs)
BFmap_RESS_select_cs(31) %.484; not impressive

%see no effect; small Bayes Factors close to 1 (smaller means more support
%for null in this case)
log10(.484)





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


epoch = 301:1300;
sizeEpochInSecs = length(epoch)*2/1000;
fstep = 1/sizeEpochInSecs;
faxis = 0:.5:250;


%% get ssVEP ERP wrong
% Get all matching files first
filemat_all = getfilesindir(pwd, 'gaborgentone_*.trls.*.mat');
% Now filter out the ones that contain '.trls.21.'
exclude_pattern = 'trls.21.mat';
keep_idx = ~contains(string(filemat_all), '.trls.21.');
% Apply logical indexing to keep only desired filenames
filemat = filemat_all(keep_idx, :);

for i = 1:size(filemat, 1)
    % Load file and extract matrix
    fname = deblank(filemat(i, :));
    data = load(fname, '-mat');

    % Assumes the variable is called Mat3D
    if isfield(data, 'Mat3D')
        dat = data.Mat3D;
    else
        warning(['Mat3D not found in file: ' fname]);
        continue
    end

    % Average over 3rd dimension
    avgmat = mean(dat, 3, 'omitnan');

    % Generate output filename
    [~, name, ~] = fileparts(fname);
    outfile = [name '_avg.mat'];

    % % Save the averaged matrix
    % save(outfile, 'avgmat', '-mat');
    % disp(['Saved: ' outfile])
end


filematavg = getfilesindir(pwd, 'gaborgentone_*.trls.*_avg.mat');
ERP = avgmats_mat(filematavg, 'ERP_Oz.mat');
ERP_Oz = load('ERP_Oz.mat');
ERP_Oz = ERP_Oz.avgmat;
figure
plot(taxis, ERP_Oz(75, :));

%% Get FFT spectrum files ('.spec') and merge across conditions
cd /Users/csea/Documents/SarahLab/Sarah_Data/GaborgenTone/Data/pipeline/data-600/spectra/Spec;

filemat = getfilesindir(pwd, '*.spec');
mergemulticons(filemat, 4, 'GM22.singletrialspec');

 [outmat] = extractstats(filemat, 4, [70 71 74 75 76 82 83] , 31, []);

% we saved the stat matrix to a file called resspower4cons.csv

% to further examine this with method with higher sensitivity, we examined the largest effect visible post-hoc
% Build repmat for statistical analysis: sensors x frequencies x subjects x conditions
[repmatsingleSpec] = makerepmat(filemat, 22, 4, []);
%
[Fcontmat,rcontmat,MScont,MScs, dfcs]=contrast_rep_sign(squeeze(repmatsingleSpec(:, 31, :, :)) ,[1.5 .5 -.5 -1.5]);

% now do the permutation test to see if this survives
for draw = 1:1000

    for x = 1:22
        repmatsingleSpec(:, :, x, 1:4) =  repmatsingleSpec(:, :,x, randperm(4));
    end

    [Fcontmat,rcontmat,MScont,MScs, dfcs]=contrast_rep_sign(squeeze(repmatsingleSpec(:, 31, :, :)) ,[1.5 .5 -.5 -1.5]);

    dist(draw) = max(Fcontmat);

    if draw./100 == round(draw./100), fprintf('.'), end

end

hist(dist, 50)
quantile(dist, .95)

% Load merged condition files for plotting/statistics
csplus = ReadAvgFile('GM22.singletrialspec.at1');
GS1 = ReadAvgFile('GM22.singletrialspec.at2');
GS2 = ReadAvgFile('GM22.singletrialspec.at3');
GS3 = ReadAvgFile('GM22.singletrialspec.at4');


%
figure
plot(faxisFFT(1:50),GS1(75, 1:50), LineWidth=2),hold on,
plot(faxisFFT(1:50),GS2(75, 1:50), LineWidth=2),
plot(faxisFFT(1:50),GS3(75, 1:50), LineWidth=2),
plot(faxisFFT(1:50),csplus(70, 1:50), 'r', LineWidth=2)
title('Frequency Spectra by Condition', 'FontSize', 22)
xlabel('Frequency (Hz)', 'FontSize', 20) % Label for x-axis
ylabel('Power', 'FontSize', 20) % Label for y-axis
legend({'GS1', 'GS2', 'GS3', 'CS+'}, 'FontSize', 20) % Adding legend





ssvep21 = csplus(75,31);
ssvep22 = GS1(75,31);
ssvep23 = GS2(75,31);
ssvep24 = GS3(75,31), 2;
% Transpose if needed so rows = subjects, columns = conditions
alpha_gm = [alphagm21; alphagm22; alphagm23; alphagm24]';  % size: [4 x N_conditions]
alpha_mean = mean(alpha_gm, 1);  % Mean across participants
alpha_sem  = std(alpha_gm, 0, 1) / sqrt(size(alpha_gm, 1));  % Standard Error of Mean (SEM)

% Plot with error bars
figure;
% bar(alpha_mean);
hold on
errorbar(1:length(alpha_mean), alpha_mean, alpha_sem);
xlabel('Condition');
ylabel('Alpha Power (Grand Mean ± SEM)');
xticks(1:length(alpha_mean));
xticklabels({'Cond1','Cond2','Cond3','Cond4'}); 
title('Alpha Power Across Conditions');






% examine with emegs2d
emegs2d

%% Bayes bootstrapping for single-trial spectra - linear
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
        disp(['draw ', num2str(draw)])
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

%% load permuted bf
load('single_Spec_linearBootPerm.mat')
%% Compare the bootstrapped with permuted data
for elec = 1:size(repmatsingleSpec,1)
    for  frequency = 1:size(repmatsingleSpec,2)
        BFmap_singleSpec_linear(elec, frequency) = bootstrap2BF_z(squeeze(linearBootstrap(elec, frequency, :)),squeeze(linearBootstrapPerm(elec, frequency, :)), 0);
    end
    disp(['elec', num2str(elec)])
end

faxisFFT = 0:.5:250;
faxisFFT(31) %15 hz

figure, plot(BFmap_singleSpec_linear(:, 31)) %select frequency of interest for all channels (15 hz which is the 31st bin)

cd /Users/csea/Documents/SarahLab/Sarah_Data/GaborgenTone/Data/pipeline/data-600/spectra/Spec
% use SaveAvgFile to create file to use in emegs for heads
AvgMat = BFmap_singleSpec_linear;
SaveAvgFile('BF_singleSpec_linear.at',AvgMat,[],[], 1,[],[],[],[],1) 

log10_BFssVEP_linear = log10(BFmap_singleSpec_linear);
SaveAvgFile('log10_BFssVEP_linear.at', log10_BFssVEP_linear,[],[], 1,[],[],[],[],1)

log10_BFssVEP_linear(75, 31)

figure, plot(BFmap_singleSpec_linear(:, 31)) %select frequency of interest for all channels (15 hz which is the 31st bin)
size(repmatsingleSpec)

plot(squeeze(repmatsingleSpec(83, 31, :, :)))
plot(squeeze(repmatsingleSpec(83, 31, :, :))')
plot(squeeze(repmatsingleSpec(83, 31, :, 1))-squeeze(repmatsingleSpec(83, 31, :, 4)))
bar(squeeze(repmatsingleSpec(83, 31, :, 1))-squeeze(repmatsingleSpec(83, 31, :, 4)))
bar(mean(squeeze(repmatsingleSpec(75, 31, :, :)))')

%% selective ssvep single trial spectra, bayes bootstrapping for single-trial spectra
clear
clc
cd /Users/csea/Documents/SarahLab/Sarah_Data/GaborgenTone/Data/pipeline/data-600/spectra/Spec
% uses the repmatsingleSpec: 129 channels, 500 freqs, 22 people, 4 conds
load('repmatsingleSpec.mat')
selectBootstrap =[];
size(repmatsingleSpec)
nsubjects = size(repmatsingleSpec, 3);
% make distributions of effects
selecteffect = [3 -1 -1 -1];


% the all or nothing effect distribution
for elec = 1:size(repmatsingleSpec,1)
    for  frequency = 1:size(repmatsingleSpec,2)
        for draw = 1:2000
            bootstrapvec = randi(nsubjects, 1,nsubjects)';
            selectBootstrap(elec, frequency, draw) = mean(squeeze(repmatsingleSpec(elec, frequency, bootstrapvec, : )), 1) * selecteffect';
        end 
    end
        disp(['elec ', num2str(elec)])
end


%% selective pattern
% the null distribution permutation
selectBootstrapPerm = [];

for perm = 1:2000
    repeatmatperm_singleSpec = repmatsingleSpec;
    for subject = 1:nsubjects
        repeatmatperm_singleSpec(: , :, subject, 1:4) = repmatsingleSpec(: , :, subject, randperm(4));
    end

    for elec = 1:size(repmatsingleSpec,1)
        for  frequency = 1:size(repmatsingleSpec,2)
            bootstrapvec = randi(nsubjects, 1,nsubjects)';
            selectBootstrapPerm(elec, frequency, perm) = mean(squeeze(repeatmatperm_singleSpec(elec, frequency, bootstrapvec, : )), 1) * lineareffect';

        end
    end
    disp(['draw ', num2str(perm)])

end

%saved as selectBootstrapPerm_singleSpec.mat

%% Compare the bootstrapped with permuted data
for elec = 1:size(repmatsingleSpec,1)
    for  frequency = 1:size(repmatsingleSpec,2)
        BFmap_singleSpec_select(elec, frequency) = bootstrap2BF_z(squeeze(selectBootstrap(elec, frequency, :)),squeeze(selectBootstrapPerm(elec, frequency, :)), 0);
    end
    disp(['elec', num2str(elec)])
end

faxisFFT = 0:.5:250;
faxisFFT(31) %15 hz

figure, plot(BFmap_singleSpec_select(:, 31)) %select frequency of interest for all channels (15 hz which is the 31st bin)

%
SaveAvgFile('BF_singleSpec_select.at',BFmap_singleSpec_select,[],[], 1,[],[],[],[],1) 
%need to make heads for single trial spec;
emegs2d

log10_BFssVEP_select = log10(BFmap_singleSpec_select);
SaveAvgFile('log10_BFssVEP_select.at', log10_BFssVEP_select,[],[], 1,[],[],[],[],1)

log10_BFssVEP_select(75, 31)

%% Alpha Wavelet Analysis
clear
clc

% Set working directory 
cd /Users/csea/Documents/SarahLab/Sarah_Data/GaborgenTone/Data/pipeline/data-600/'New Folder'/;
% cd /Users/andreaskeil/Desktop/gaborgentone/trial3dmats
% Define frequency and time axes for wavelet analysis
faxisall = 0:1000/3600:250;    % full frequency axis for wavelets
faxis = faxisall(11:4:110);      % frequency axis used for plotting
taxis = (-598:2:3000);           % time axis in ms

% Run wavelet analysis on trial files (returns power, phase-locking index, etc.)
filemat = getfilesindir(pwd, 'gabor*trls.2*.mat');
[WaPower, PLI, PLIdiff] = wavelet_app_matfiles(filemat, 500, 11, 110, 4, 200:300, []); %baseline corr but not an issue bc its before waveletting

% Process power files and group by condition:
filematpow = getfilesindir(pwd, 'gabor*pow3.mat');
filematpow21 = filematpow(1:4:end, :);
filematpow22 = filematpow(2:4:end, :);
filematpow23 = filematpow(3:4:end, :);
filematpow24 = filematpow(4:4:end, :);

% Compute grand means for each condition
GM22pow3_21 = avgmats_mat(filematpow21, 'GM22.at21.pow3.mat');
GM22pow3_22 = avgmats_mat(filematpow22, 'GM22.at22.pow3.mat');
GM22pow3_23 = avgmats_mat(filematpow23, 'GM22.at23.pow3.mat');
GM22pow3_24 = avgmats_mat(filematpow24, 'GM22.at24.pow3.mat');

gm22 = getfilesindir(pwd, 'GM22.at2*'); %all except CS+ condition
GM22_all = avgmats_mat(gm22, 'GM22_all.mat');
% GM22_all = permute(GM22_all,[2 1 3]);
SaveAvgFile('GM22_all.at',GM22_all,[],[], 1,[],[],[],[],1)


%% time-freq plot for paper for channel 75 avg over all except cs+
% filematGM = getfilesindir(pwd, 'GM22.at2*.pow3.mat') 
% GM22_all = avgmats_mat(filematGM, 'GM22_all.mat');
load('GM22_all.mat')
GM22_all_bsl = bslcorrWAMat_percent(GM22_all, 125:240);


% Define frequency and time axes for wavelet analysis
faxisall = 0:1000/3600:250;    % full frequency axis for wavelets
faxis = faxisall(11:4:110);      % frequency axis used for plotting
taxis = -598:2:3000;           % time axis in ms


% Plot baseline-corrected contours
figure
subplot(2,1,1), contourf(taxis, faxis, squeeze(GM22_all(sensor,:,:))'), colorbar
subplot(2,1,2), contourf(taxis, faxis, squeeze(GM22_all_bsl(sensor,:,:))'), colorbar

%%

%load grand means for each condition
GM22pow3_21 = importdata('GM22.at21.pow3.mat', 'avgmat');
GM22pow3_22 = importdata('GM22.at22.pow3.mat', 'avgmat');
GM22pow3_23 = importdata('GM22.at23.pow3.mat', 'avgmat');
GM22pow3_24 = importdata('GM22.at24.pow3.mat', 'avgmat');

GM22pow3_21 = GM22pow3_21(:, :, 8);
GM22pow3_22 = GM22pow3_22(:, :, 8);
GM22pow3_23 = GM22pow3_23(:, :, 8);
GM22pow3_24 = GM22pow3_24(:, :, 8);
%save as at files for emegs
SaveAvgFile('GM22powAlpha_21_alpha.at',GM22pow3_21,[],[], 1,[],[],[],[],1) 
SaveAvgFile('GM22powAlpha_22_alpha.at',GM22pow3_22,[],[], 1,[],[],[],[],1) 
SaveAvgFile('GM22powAlpha_23_alpha.at',GM22pow3_23,[],[], 1,[],[],[],[],1) 
SaveAvgFile('GM22powAlpha_24_alpha.at',GM22pow3_24,[],[], 1,[],[],[],[],1) 
emegs2d


% Plot contour plots for a selected sensor
sensor = 75;
faxisindex = 4:20;
figure
subplot(4,1,1), contourf(taxis(50:end-50), faxis(faxisindex), squeeze(GM22pow3_21(sensor,50:end-50, faxisindex))', 15)%, caxis([.4 5]),colorbar
subplot(4,1,2), contourf(taxis(50:end-50), faxis(faxisindex), squeeze(GM22pow3_22(sensor,50:end-50, faxisindex))', 15)%, caxis([.4 5]),colorbar
subplot(4,1,3), contourf(taxis(50:end-50), faxis(faxisindex), squeeze(GM22pow3_23(sensor,50:end-50, faxisindex))', 15)%, caxis([.4 5]),colorbar
subplot(4,1,4), contourf(taxis(50:end-50), faxis(faxisindex), squeeze(GM22pow3_24(sensor,50:end-50, faxisindex))', 15)%, caxis([.4 5]),colorbar
sgtitle(['Average Power by Condition: Sensor ' num2str(sensor)])%


alphagm21 = GM22pow3_21(75,450:800);
alphagm22 = GM22pow3_22(75,450:800);
alphagm23 = GM22pow3_23(75,450:800);
alphagm24 = GM22pow3_24(75,450:800);
alpha_gm = [alphagm21; alphagm22; alphagm23; alphagm24]'; 
alpha_mean = mean(alpha_gm, 1);  % Mean across participants
alpha_sem  = std(alpha_gm, 0, 1) / sqrt(size(alpha_gm, 1));  % Standard Error of Mean (SEM)

% Plot with error bars
figure;
bar(alpha_mean);
hold on
errorbar(1:length(alpha_mean), alpha_mean, alpha_sem);
xlabel('Condition');
ylabel('Alpha Power (Grand Mean ± SEM)');
xticks(1:length(alpha_mean));
xticklabels({'Cond1','Cond2','Cond3','Cond4'}); 
title('Alpha Power Across Conditions');



%% Baseline-correct the grand means (using baseline indices 125:240)
GM22pow3_21_bsl = bslcorrWAMat_percent(GM22pow3_21, 75:225);
GM22pow3_22_bsl = bslcorrWAMat_percent(GM22pow3_22, 75:225);
GM22pow3_23_bsl = bslcorrWAMat_percent(GM22pow3_23, 75:225);
GM22pow3_24_bsl = bslcorrWAMat_percent(GM22pow3_24, 75:225);

% %save as at files for emegs
% SaveAvgFile('GM22powAlpha_21_alpha_bsl.at',GM22pow3_21,[],[], 1,[],[],[],[],1) 
% SaveAvgFile('GM22powAlpha_22_alpha_bsl.at',GM22pow3_22,[],[], 1,[],[],[],[],1) 
% SaveAvgFile('GM22powAlpha_23_alpha_bsl.at',GM22pow3_23,[],[], 1,[],[],[],[],1) 
% SaveAvgFile('GM22powAlpha_24_alpha_bsl.at',GM22pow3_24,[],[], 1,[],[],[],[],1) 


% Plot baseline-corrected contoursfor alpha frequencies
figure
% faxisindex = 6:18;
faxisindex = 8;
sensor = 75;%

subplot(4,1,1), contourf(taxis(50:end-50), faxis(faxisindex), squeeze(GM22pow3_21_bsl(sensor,50:end-50,faxisindex))')%, colorbar%, caxis([-15 100])
subplot(4,1,2), contourf(taxis(50:end-50), faxis(faxisindex), squeeze(GM22pow3_22_bsl(sensor,50:end-50,faxisindex))')%, colorbar%, caxis([-15 100])
subplot(4,1,3), contourf(taxis(50:end-50), faxis(faxisindex), squeeze(GM22pow3_23_bsl(sensor,50:end-50,faxisindex))')%, colorbar%, caxis([-15 100])
subplot(4,1,4), contourf(taxis(50:end-50), faxis(faxisindex), squeeze(GM22pow3_24_bsl(sensor,50:end-50,faxisindex))')%, colorbar%, caxis([-15 100])
sgtitle(['Average Power by Condition: Sensor ' num2str(sensor)])

time = 1050:1125;
%plot alpha differences by condition over time
figure
plot(taxis(time), squeeze(GM22pow3_21_bsl(75, time)))
hold on
plot(taxis(time), squeeze(GM22pow3_22_bsl(75, time)))
plot(taxis(time), squeeze(GM22pow3_23_bsl(75, time)))
plot(taxis(time), squeeze(GM22pow3_24_bsl(75, time)))




%% we used ttest3d to easily obtain 4-D arrays
% [ttestmat21_22, ~, mat4d22] = ttest3d(filematpow21, filematpow22, 1, []);
% [ttestmat21_23, ~, mat4d23] = ttest3d(filematpow21, filematpow23, 1, []);
% [ttestmat21_24, mat4d21, mat4d24] = ttest3d(filematpow21, filematpow24, 1, []);


%load in 4-d arrays
load('mat4d21_csplus.mat')
load('mat4d22_gs1.mat')
load('mat4d23_gs2.mat')
load('mat4d24_gs3.mat')

 repeatmat_alpha = cat(5, mat4d21(:, 1:10:end, :, :), mat4d22(:, 1:10:end, :, :), mat4d23(:, 1:10:end, :, :), mat4d24(:, 1:10:end, :, :));

 [ttestmat21_22, ~, mat4d22_bsl] = ttest3d(filematpow21, filematpow22, 1, [75:225]);
[ttestmat21_23, ~, mat4d23_bsl] = ttest3d(filematpow21, filematpow23, 1, [75:225]);
[ttestmat21_24, mat4d21_bsl, mat4d24_bsl] = ttest3d(filematpow21, filematpow24, 1, [75:225]);

     repeatmat_alpha_bsl = cat(5, mat4d21_bsl(:, 1:10:end, :, :), mat4d22_bsl(:, 1:10:end, :, :), mat4d23_bsl(:, 1:10:end, :, :), mat4d24_bsl(:, 1:10:end, :, :));

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
plot(taxis(1:10:end), Fcontmat_CSselectWavelet(72,:,8))
title('F tests for alpha - Sensor 72')

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


%% do the bayesian bootstrap for Alpha Power; 
% uses the repeatmat
linearBootstrap =[];
size(repeatmat_alpha)
nsubjects = size(repeatmat_alpha, 4); 
% make distributions of effects
lineareffect = [-2 -1 1 2]; %expect this direction of effect

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
    disp(['draw ', num2str(draw)])
end

%%
% the null distribution permutation
linearBootstrapPerm = [];
for perm = 1:2000
    repeatmat_alphaperm = repeatmat_alpha;
    for subject = 1:nsubjects
        repeatmat_alphaperm(:, :, :, subject, :) = repeatmat_alphaperm(:, :, :, subject, randperm(4));
    end
     bootstrapvec = randi(nsubjects, 1,nsubjects)';
    for elec = 1:size(repeatmat_alpha,1)
        for timepoint = 1:size(repeatmat_alpha,2)
            for  frequency = 1:size(repeatmat_alpha,3)
               
                linearBootstrapPerm(elec, timepoint, frequency, perm) = ...
                mean(squeeze(repeatmat_alphaperm(elec,timepoint, frequency, bootstrapvec, : ))) * lineareffect';
            end
        end
        
    end
    disp(['permutation ', num2str(perm)])
end



%% comparison between wavelet and permuted values
% BFmap_alpha results in 129 channels x 180 timepoints x 25 frequencies
for elec = 1:size(repeatmat_alpha,1)
    for timepoint = 1:size(repeatmat_alpha,2) %180 timepoints, decimated earlier
        for  frequency = 1:size(repeatmat_alpha,3) %25 frequencies, decimated earlier (8th is alpha)
            BFmap_alpha(elec, timepoint, frequency) = bootstrap2BF_z(squeeze(linearBootstrap(elec,timepoint, frequency, :)), ...
                squeeze(linearBootstrapPerm(elec,timepoint, frequency, :)), 0);
        end
    end
    disp(['elec', num2str(elec)])
end
%%
plot(BFmap_alpha(75,:,8)) %faxis shows alpha is now 8th in 3rd dimension
%[75 62 55 81 72]

%%
alphaBF = BFmap_alpha(:,:,8);
SaveAvgFile('alphaBF.at', alphaBF, [], [],1,[],[],[],[],1)
emegs2d



%% do the bayesian bootstrap for Alpha Power - selective pattern; 
% uses the repeatmat
selectBootstrap_alpha =[];
size(repeatmat_alpha)
nsubjects = size(repeatmat_alpha, 4); 
% make distributions of effects
selecteffect = [-3 1 1 1]; %expect this direction of effect

% the linear effect distribution
for draw = 1:2000
    bootstrapvec = randi(nsubjects, 1,nsubjects)';
    for elec = 1:size(repeatmat_alpha,1)
        for timepoint = 1:size(repeatmat_alpha,2)
            for  frequency = 1:size(repeatmat_alpha,3)
                selectBootstrap_alpha(elec, timepoint, frequency, draw) = ...
                    mean(squeeze(repeatmat_alpha(elec, timepoint, frequency, bootstrapvec, : ))) * selecteffect';
            end
        end
    end
    disp(['draw ', num2str(draw)])
end

%% the null distribution permutation
selectBootstrapPerm_alpha = [];
for perm = 1:2000
    repeatmat_alphaperm = repeatmat_alpha;
    for subject = 1:nsubjects
        repeatmat_alphaperm(:, :, :, subject, :) = repeatmat_alphaperm(:, :, :, subject, randperm(4));
    end
     bootstrapvec = randi(nsubjects, 1,nsubjects)';
    for elec = 1:size(repeatmat_alpha,1)
        for timepoint = 1:size(repeatmat_alpha,2)
            for  frequency = 1:size(repeatmat_alpha,3)
               
                selectBootstrapPerm_alpha(elec, timepoint, frequency, perm) = ...
                mean(squeeze(repeatmat_alphaperm(elec,timepoint, frequency, bootstrapvec, : ))) * selecteffect';
            end
        end
        
    end
    disp(['permutation ', num2str(perm)])
end



%% comparison between wavelet and permuted values
% BFmap_alpha results in 129 channels x 180 timepoints x 25 frequencies
for elec = 1:size(repeatmat_alpha,1)
    for timepoint = 1:size(repeatmat_alpha,2) %180 timepoints, decimated earlier
        for  frequency = 1:size(repeatmat_alpha,3) %25 frequencies, decimated earlier (8th is alpha)
            BFmap_alpha_select(elec, timepoint, frequency) = bootstrap2BF_z(squeeze(selectBootstrap(elec,timepoint, frequency, :)), ...
                squeeze(selectBootstrapPerm_alpha(elec,timepoint, frequency, :)), 0);
        end
    end
    disp(['elec', num2str(elec)])
end

%% read in at files that andreas sent; already logged
linear = ReadAvgFile('Log10TypicalLinearBFs.at');
antilinear = ReadAvgFile('Log10AntiLinearBFs.at');
antiallnothing = ReadAvgFile('Log10allnothingBFs.at');

allnothing = antiallnothing* -1;
SaveAvgFile('Log10allnothingBF_typical.at',allnothing,[],[], ...
    [],[],[],[],[],[],[],[],[],[],[])

early_bfmap_linear = squeeze(mean(linear (75, 30:65), 2))
middle_bfmap_linear = squeeze(mean(linear(75, 65:95), 2))
late_bfmap_linear = squeeze(mean(linear  (75, 95:130), 2))
% antilinear  : [129 × 180] matrix of log10 Bayes factors
%               (129 electrodes, 180 decimated time-samples)

%% Channel 70/75, three time windows; BFs
% early_bfmap_linear  = mean(linear(75, 31:63))  % 0–660 ms
% middle_bfmap_linear = mean(linear(75, 64:97))   % 670–1330 ms
% late_bfmap_linear   = mean(linear(75, 98:130))  % 1340–2000 ms

early_bfmap_allnothing  = mean(allnothing(70, 30:65))  % ~0–700 ms 
middle_bfmap_allnothing = mean(allnothing(70, 65:95))   % ~700–1300 ms 
late_bfmap_allnothing  = mean(allnothing(70, 95:130))  % ~1300–2000 ms

%%
alphaBF_select = BFmap_alpha_select(:,:,8);
SaveAvgFile('alphaBF_select.at', alphaBF_select, [], [],1,[],[],[],[],1)
emegs2d

