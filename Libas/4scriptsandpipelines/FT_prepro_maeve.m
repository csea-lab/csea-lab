function [outmat3d_AR] = FT_prepro_maeve(filemat, lpfreq, hpfreq, pretrig, posttrig)


for fileindex = 1:size(filemat,1)
disp(fileindex)
outname  = deblank(filemat(fileindex,1:end-3)); 

%load data    
rawfile                     = filemat(fileindex,:); 
% provide continuous data
cfg                         = [];
cfg.dataset                 = rawfile;

cfg.trialdef.eventtype      = 'DIN3';
cfg.trialdef.pre            = pretrig; % seconds
cfg.trialdef.post            = posttrig; % seconds
cfg.trialfun                = 'trialfun_maeve'
cfg                         = ft_definetrial(cfg);

cfg.channel                 = {'eeg'};
% preprocess
cfg.continuous              = 'yes';
cfg.demean                  = 'yes'; % yes, do mean-based baseline correction
% cfg.baselinewindow          = [-4 0];
cfg.lpfilter                = 'yes'; % yes, lowpass it
cfg.lpfreq                  = lpfreq;
cfg.hpfilter                = 'yes'; % yes, highpass it
cfg.hpfreq                  = hpfreq;
  
data                        = ft_preprocessing(cfg);

 fprintf('\n\n\n FINISHED SEGMENTING & PREPROCESSING! \n\n\n')

%%
%bad channels continuous
load('elekFieldTrip257HCL.mat') % loads "sensors" matrix
% get bad channels across the entire recording
EEG                         = [];
EEG.continuous              = ft_read_data(rawfile); % faster way?
[badindex_chan] = scadsAK_2dchan(EEG.continuous, 1.5);
EEG.outliers                = [badindex_chan];
EEG.label                   = sensors.label;
badchannel                  = ft_channelselection(EEG.outliers, EEG.label);

% find nearest neighbors                            
cfg                         = []; 
cfg.method                  = 'distance';
cfg.elec                    = sensors;
cfg.neighbourdist           = 3;
neighbours                  = ft_prepare_neighbours(cfg);

% channel Repair                           
cfg                         = []; 
cfg.method                  = 'spline';
cfg.missingchannel          = [];
cfg.badchannel              = badchannel;
cfg.trials                  = 'all';
cfg.lambda                  = 1e-5;
cfg.order                   = 4;
cfg.neighbours              = neighbours;
data.elec                   = sensors;
data                      = ft_channelrepair(cfg, data);

%% bad channels segmented
load('locsEEGLAB257HCL.mat');
interpsens = [];
for trial = 1:size(data.trial,2)
inmat2d = data.trial{1, trial};
[outmat2d, interpvec] = scadsAK_2dInterpChan(inmat2d, locsEEGLAB257HCL);
data.trial{1,trial} = outmat2d;
data.badchannel{1,trial} = interpvec;
interpsens = [interpsens cell2mat(data.badchannel(:,trial))];
interpsens2 = unique(interpsens);
end

for trial = 1:size(data.trial,2)
inmat3d(:,:,trial) = cell2mat(data.trial(1,trial));
end
%%
% bad trials 

[ outmat3d, badindex_trial, goodindex ] = scadsAK_3dtrials(inmat3d);
% todo: make nans instead of empty, so that trials match log file

%average reference
outmat3d_AR = avg_ref_add3d(outmat3d); 

%% save everything you want
%eval(['save ' outname 'appg.mat outmat3d_AR'])
%eval(['save ' outname 'ig.mat goodindex'])

end %fileloop
fprintf('done')

end %function

