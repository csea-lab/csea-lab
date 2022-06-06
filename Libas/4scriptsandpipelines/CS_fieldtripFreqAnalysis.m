
% first change path to the needed source files
% /home/keil-admin/Desktop/Data/Condispas/FTsourceLocFiles
% to load necessary location files
load resliced.mat
load segmentedmri.mat
load bnd.mat
load vol.mat
load segmentedmri_tpm.mat
load sourcemodel_end
load elec_aligned.mat

% after files are loaded, change path to where the .app mat files are
% /home/keil-admin/Desktop/Data/Condispas/condispas_app/mat_files
% and make filemat

% make filemat of app**.mat files
% then subdivide filemat to get get activity at each location in hab
% ex: filemat3 = filemat(3:10:end,:);
for idx = 1:size(filemat3,1) %pos 3, habituation
    % make filemat of app**.mat files
tmp = load(filemat(idx,:)); % just manually changing for now
EEG = pop_importdata('dataformat','matlab','nbchan',0,'data',tmp.outmat,'srate',500,'pnts',1251,'xmin',-0.5);
EEG=pop_chanedit(EEG, 'load',{'GSN-HydroCel-129.sfp' 'filetype' 'autodetect'});
data = eeglab2fieldtrip( EEG, 'preprocessing', 'none' );
data.dimord        = 'chan_time';
data.elec = elec_aligned; 
[channel] = ft_channelselection({'all', '-Fid*'}, elec_aligned, 'eeg'); %
% /////      all the weird FT cfg steps start here /////
cfg = []; 
cfg.covariance = 'yes';
[timelock] = ft_timelockanalysis(cfg, data); 
% Still time domain at this point
%% uncomment for plot
% cfg = [];
% cfg.parameter = 'avg'; 
% cfg.channel = {'E75'}
% ft_singleplotER(cfg, timelock)
%%
cfg  = []; 
cfg.toilim    = [0.2 2];  % how determined ?
[timelock] = ft_redefinetrial(cfg, timelock); % why the new timelocking ? - just for segmentation ?

% freq analysis
wholetime = data.time{1}; % is this just taking one trial, or avging over trials?
cfg = [];
cfg.method = 'mtmfft';  % better than 'tfr' ?
cfg.output = 'powandcsd';
cfg.toi = wholetime(351:1251); % time window "slides" by 1 bin, bin 351=.2 sec, 
% bin 1251=2 sec in increments of .002, .002 sec=2 ms
cfg.tapsmofrq = .55;
% cfg.foilim   = [3 35];
% cfg.foilim   = [13 17]; % provides 9 freqs for SNR
cfg.foi      = 15;
cfg.keeptrials = 'no'; % should be 'no' by default anyway, just checking
[freq] = ft_freqanalysis(cfg, timelock);

%% uncomment to sub SNR for 15 hz power
% freq.powspctrm(:,5) =freq.powspctrm(:,5) ./ mean(freq.powspctrm(:,[1:3,7:9]),2);
% figure; plot(freq10.freq, freq10.powspctrm(78,:))
%% source estimation - could use an 'eval' to reduce the loop below
cfg = []; 
cfg.method = 'eloreta';
cfg.sourcemodel = sourcemodel_end;
cfg.channel  = channel; 
cfg.elec = elec_aligned; 
cfg.headmodel = vol;
cfg.lambda = 3;
if idx==1
[source1] = ft_sourceanalysis(cfg, freq);
elseif idx==2
    [source2] = ft_sourceanalysis(cfg, freq);
elseif idx==3
    [source3] = ft_sourceanalysis(cfg, freq);
elseif idx==4
    [source4] = ft_sourceanalysis(cfg, freq);
elseif idx==5
    [source5] = ft_sourceanalysis(cfg, freq);
elseif idx==6
    [source6] = ft_sourceanalysis(cfg, freq);
elseif idx==7
    [source7] = ft_sourceanalysis(cfg, freq);
    elseif idx==8
    [source8] = ft_sourceanalysis(cfg, freq);
    elseif idx==9
    [source9] = ft_sourceanalysis(cfg, freq);
    elseif idx==10
    [source10] = ft_sourceanalysis(cfg, freq);
    elseif idx==11
    [source11] = ft_sourceanalysis(cfg, freq);
    elseif idx==12
    [source12] = ft_sourceanalysis(cfg, freq);
    elseif idx==13
    [source13] = ft_sourceanalysis(cfg, freq);
    elseif idx==14
    [source14] = ft_sourceanalysis(cfg, freq);
    elseif idx==15
    [source15] = ft_sourceanalysis(cfg, freq);
    elseif idx==16
    [source16] = ft_sourceanalysis(cfg, freq);
    elseif idx==17
    [source17] = ft_sourceanalysis(cfg, freq);
    elseif idx==18
    [source18] = ft_sourceanalysis(cfg, freq);
    elseif idx==19
    [source19] = ft_sourceanalysis(cfg, freq);
    elseif idx==20
    [source20] = ft_sourceanalysis(cfg, freq);
elseif idx==21
    [source21] = ft_sourceanalysis(cfg, freq);
    elseif idx==22
    [source22] = ft_sourceanalysis(cfg, freq);
    elseif idx==23
    [source23] = ft_sourceanalysis(cfg, freq);
    elseif idx==24
    [source24] = ft_sourceanalysis(cfg, freq);
    elseif idx==25
    [source25] = ft_sourceanalysis(cfg, freq);
    elseif idx==26
    [source26] = ft_sourceanalysis(cfg, freq);
    elseif idx==27
    [source27] = ft_sourceanalysis(cfg, freq);
    elseif idx==28
    [source28] = ft_sourceanalysis(cfg, freq);
    elseif idx==29
    [source29] = ft_sourceanalysis(cfg, freq);
    elseif idx==30
    [source30] = ft_sourceanalysis(cfg, freq);
    elseif idx==31
    [source31] = ft_sourceanalysis(cfg, freq);
elseif idx==32
    [source32] = ft_sourceanalysis(cfg, freq);
elseif idx==33
    [source33] = ft_sourceanalysis(cfg, freq);
elseif idx==34
    [source34] = ft_sourceanalysis(cfg, freq);
elseif idx==35
    [source35] = ft_sourceanalysis(cfg, freq);
elseif idx==36
    [source36] = ft_sourceanalysis(cfg, freq);
elseif idx==37
    [source37] = ft_sourceanalysis(cfg, freq);
elseif idx==38
    [source38] = ft_sourceanalysis(cfg, freq);
elseif idx==39
    [source39] = ft_sourceanalysis(cfg, freq);
elseif idx==40
    [source40] = ft_sourceanalysis(cfg, freq);
elseif idx==41
    [source41] = ft_sourceanalysis(cfg, freq);
elseif idx==42
    [source42] = ft_sourceanalysis(cfg, freq);
elseif idx==43
    [source43] = ft_sourceanalysis(cfg, freq);
elseif idx==44
    [source44] = ft_sourceanalysis(cfg, freq);
elseif idx==45
    [source45] = ft_sourceanalysis(cfg, freq);
elseif idx==46
    [source46] = ft_sourceanalysis(cfg, freq);
elseif idx==47
    [source47] = ft_sourceanalysis(cfg, freq);
elseif idx==48
    [source48] = ft_sourceanalysis(cfg, freq);
elseif idx==49
    [source49] = ft_sourceanalysis(cfg, freq);
elseif idx==50
    [source50] = ft_sourceanalysis(cfg, freq);
else
    [source51] = ft_sourceanalysis(cfg, freq);
end
end

%% now grandavg
[grandavg3] = ft_sourcegrandaverage(cfg,source1,source2,source3,source4,source5,source6,...
source7,source8 ,source9,source10,source11,source12,source13,source14,source15,source16,...   
source17,source18,source19,source20, source21,source22,source23,source24,source25, source26,...
source27,source28,source29,source30, source31,source32,source33,source34,source35,source36,...
source37,source38,source39,source40, source41,source42,source43,source44,source45, source46,...
source47,source48,source49,source50, source51);

%% Display the source data
% interpolate the low-res functional data onto the high-res anatomy
% https://www.fieldtriptoolbox.org/tutorial/plotting/
% variable 'resliced' has the mri info
cfg            = [];
% cfg.downsample = 5; % downsample to look at with FT, don't for saving to
% nifti
cfg.parameter  = 'pow';
sourceInt  = ft_sourceinterpolate(cfg, grandavg3 , resliced);

% plot with FT - only 'ortho' seems to work with freq data
cfg = [];  
cfg.method =  'ortho'
cfg.funcolorlim = [.002 .01]
cfg.funparameter = 'avg.pow'
% cfg.latency = 1; % what does this do ??
% cfg.frequency = 'all';
cfg.frequency = 15;
% cfg.funcolormap = 'jet'
ft_sourceplot(cfg, sourceInt, resliced)
% compare to non-interpolated
% ft_sourceplot(cfg, grandavg3, resliced) % looks the same

% export source and anatomical model data to nifti format 
cfg = [];
cfg.filename  = 'pos3source'; % string, filename without the extension
% cfg.filetype  = string, can be 'nifti', 'gifti' or 'cifti' (default is automatic)
cfg.parameter = 'pow'; % string, functional parameter to be written to file
cfg.precision = 'double'; 
ft_sourcewrite(cfg,sourceInt)

cfg = [];
cfg.filename  = 'FTheadmodel'; % string, filename without the extension
cfg.parameter = 'anatomy'; % string, functional parameter to be written to file
cfg.precision = 'double'; 
ft_sourcewrite(cfg,sourceInt)














