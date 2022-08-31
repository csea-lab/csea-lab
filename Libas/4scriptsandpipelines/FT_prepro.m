function [] = FT_prepro(filemat, lpfreq, hpfreq, pretrig, posttrig)


for fileindex = 1:size(filemat,1)
disp(fileindex)
outname  = [deblank(filemat(fileindex,1:end-3))]; 

%load data    
rawfile                     = filemat(fileindex,:); 
% provide continuous data
cfg                         = [];
cfg.dataset                 = rawfile;

% preprocess
cfg.continuous              = 'yes';
cfg.channel                 = {'EEG'};
cfg.demean                  = 'yes'; % yes, do mean-based baseline correction
% cfg.baselinewindow          = [-4 0];
cfg.lpfilter                = 'yes'; % yes, lowpass it
cfg.lpfreq                  = lpfreq;
cfg.hpfilter                = 'yes'; % yes, highpass it
cfg.hpfreq                  = hpfreq;

data                        = ft_preprocessing(cfg);

cfg.trialdef.eventtype      = 'DIN3';
cfg.trialdef.prestim        = pretrig; % seconds
cfg.trialdef.poststim       = posttrig; % seconds
cfg                         = ft_definetrial(cfg);

%%
% %%
% % now get rid of extra triggers
% % first take out leading triggers that are too close to recording onset
% initialbadtrials = []; 
% for x = 1:length(cfg.event)-1
% if cfg.event(x).sample < 1000*cfg.trialdef.prestim/(1000./data.fsample)
% initialbadtrials = [initialbadtrials x];  
% end
% end
% cfg.event(initialbadtrials) = [];
% cfg.trl(initialbadtrials) = [];
% 
% outtaketrials = []; 
% for x = 2:length(cfg.event)
% if cfg.event(x).sample - cfg.event(x-1).sample < 1000
% outtaketrials = [ outtaketrials x]; 
% end
% end
%    cfg.event(outtaketrials) = [];
   
%   if size(cfg.event,2) >= 200
%   cfg.event(1) =[];
%   end
%   
%   cfg.trl(outtaketrials,:) = [];
%   if size(cfg.trl,1) >= 200
%   cfg.trl(1,:) =[];
%   end
  
 data = ft_redefinetrial(cfg, data);

 fprintf('\n\n\n FINISHED SEGMENTING & PREPROCESSING! \n\n\n')

%%
%bad channels continuous
 load('EGI_HCL_129_NOfidNORM.mat')
% get bad channels
EEG                         = [];
EEG.continuous              = ft_read_data(rawfile); % faster way?
[badindex_chan] = scadsAK_2dchan(EEG.continuous, 1.5);
EEG.outliers                = [badindex_chan];
EEG.label                   = EGI_HCL_129_NOfidNORM.label;
badchannel                  = ft_channelselection(EEG.outliers, EEG.label);

% find nearest neighbors                            
cfg                         = []; 
cfg.method                  = 'distance';
cfg.elec                    = EGI_HCL_129_NOfidNORM;
cfg.neighbourdist           = 3;
neighbours                  = ft_prepare_neighbours(cfg);

% channel Repair                           % 3 fiducials
cfg                         = []; 
cfg.method                  = 'average';
cfg.missingchannel          = [];
cfg.badchannel              = badchannel;
cfg.trials                  = 'all';
cfg.lambda                  = 1e-5;
cfg.order                   = 4;
cfg.neighbours              = neighbours;
data.elec                   = EGI_HCL_129_NOfidNORM;
data                      = ft_channelrepair(cfg, data);

%% bad channels segmented
load('locsEEGLAB129HCL.mat');
interpsens = [];
for trial = 1:size(data.trial,2)
inmat2d = data.trial{1, trial};
[outmat2d, interpvec] = scadsAK_2dInterpChan(inmat2d, locsEEGLAB129HCL);

data.trial{1,trial} = outmat2d;
data.badchannel{1,trial} = interpvec;
interpsens = [interpsens cell2mat(data.badchannel(:,trial))];
interpsens2 = unique(interpsens);
end

for trial = 1:size(data.trial,2)
inmat3d(:,:,trial) = cell2mat(data.trial(1,trial));
end

[ outmat3d, badindex_trial, goodindex ] = scadsAK_3dtrials(inmat3d);

%average reference
outmat3d_AR = avg_ref_add3d(outmat3d); 

%% save everything you want
eval(['save ' outname 'appg.mat outmat3d_AR'])
eval(['save ' outname 'ig.mat goodindex'])


end %fileloop
fprintf('all done')

end %function

