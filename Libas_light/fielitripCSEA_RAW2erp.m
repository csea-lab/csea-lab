%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------
%% Parent function
%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------

function[erp_L, erp_U, erp_all, data, interp, cfg] = RAW2erp(file)

[data]                          = prepro(file);
[interp]                        = repair(file, data);
[c1]                            = extract(interp);
[erp_L, erp_U, erp_all, cfg]    = average(file, c1);

% SOME PLOTS TO HELP YOU LOOK AT THE DATA AT DIFFERENT STAGES
    % % plots
    % figure; hold on
    %     t = 1680;
    %     plot(data.trial{t}', 'r')
    %     plot(interp.trial{t}', 'c')
    % figure; hold on
    %     title('upper v. lower visual field');
    %     plot(erp_L.time, erp_L.avg, 'r');
    %     plot(erp_U.time, erp_U.avg, 'c'); 
    % 
    % figure;
    %     ft_movieplotER(cfg, erp_L)
end

%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------
%% Sub-functions
%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------

%-------------------------------------------------------------------------------
%% Segment & Preprocess Data
%-------------------------------------------------------------------------------

function [data] = prepro(file)

rawfile                     = strcat(file, '.RAW');

% provide continuous data
cfg                         = [];
cfg.dataset                 = rawfile;
cfg.trialdef.eventtype      = 'trigger';
cfg.trialdef.prestim        = .1; % seconds
cfg.trialdef.poststim       = .4; % seconds
cfg                         = ft_definetrial(cfg);

% segment and preprocess
cfg.continuous              = 'yes';
cfg.channel                 = {'EEG'};
cfg.demean                  = 'yes'; % yes, do mean-based baseline correction
cfg.baselinewindow          = [-0.1 0];
cfg.lpfilter                = 'yes'; % yes, lowpass it
cfg.lpfreq                  = 40;
cfg.ref                     = 'yes';
cfg.refchannel              = 'all';
cfg.refmethod               = 'avg';
data                        = ft_preprocessing(cfg);

fprintf('\n\n\n FINISHED SEGMENTING & PREPROCESSING! \n\n\n')
end


%-------------------------------------------------------------------------------
%% Channel Repair
%-------------------------------------------------------------------------------

function [interp] = repair(file, data)

load('EGIHCL257_fid.mat')
rawfile                     = strcat(file, '.RAW');

% get bad channels
EEG                         = [];
EEG.continuous              = ft_read_data(rawfile); % faster way?
EEG.downsampled             = EEG.continuous(:, 1:1000:end');
EEG.stdev                   = std(EEG.downsampled')';
EEG.outliers                = find(EEG.stdev > 1.0e+04*.45)+3; % 3 fiducials
EEG.label                   = EGIHCL257_fid.label;
channel                     = ft_channelselection(EEG.outliers, EEG.label);
 
% find nearest neighbors                            
cfg                         = []; 
cfg.method                  = 'distance';
cfg.elec                    = EGIHCL257_fid;
cfg.neighbourdist           = 3;
neighbours                  = ft_prepare_neighbours(cfg);

% channel Repair                           % 3 fiducials
cfg                         = []; 
cfg.method                  = 'average';
cfg.missingchannel          = [];
cfg.badchannel              = channel;
cfg.trials                  = 'all';
cfg.lambda                  = 1e-5;
cfg.order                   = 4;
cfg.neighbours              = neighbours;
data.elec                   = EGIHCL257_fid;
interp                      = ft_channelrepair(cfg, data);

% artifact rejection (THIS MAY NOT BE DOING ANYTHING RIGHT NOW)
cfg.artfctdef.zvalue.channel    = 'EEG';
cfg.artfctdef.zvalue.cutoff     = 10;
cfg.artfctdef.zvalue.trlpadding = 0;
cfg.artfctdef.zvalue.artpadding = 0;
cfg.artfctdef.zvalue.fltpadding = 0;

[cfg, artifact]                 = ft_artifact_zvalue(cfg, interp);
cfg = ft_rejectartifact(cfg.previous.previous); % Looks like I don't use this?

fprintf('\n\n\n FINISHED CHANNEL REPAIR AND ARTIFACT REJECTION! \n\n\n')
end


%-------------------------------------------------------------------------------
%% Extract trial segment
%-------------------------------------------------------------------------------

function [c1] = extract(interp)

cfg = [];
cfg.begsample = 94; % 86 ms (real time: 64 ms)
cfg.endsample = 107; % 112 ms (real time: 90 ms)
c1 = ft_redefinetrial(cfg, interp);

% cfg = [];
% cfg.begsample = 94; 
% cfg.endsample = 100; 
% c1_1 = ft_redefinetrial(cfg, interp);
% 
% cfg = [];
% cfg.begsample = 100; 
% cfg.endsample = 107; 
% c1_2 = ft_redefinetrial(cfg, interp);
% 
% cfg = [];
% cfg.begsample = 100; 
% cfg.endsample = 101; 
% c1_mid = ft_redefinetrial(cfg, interp);
% 
% components = [c1, c1_1, c1_2];
end

%-------------------------------------------------------------------------------
%% Averaging 
%-------------------------------------------------------------------------------
% This is extremely specific to the C1 study - will need to be completely 
% rewritten for a different study

function [erp_L, erp_U, erp_all, cfg] = average(file, c1)

dat.file                    = strcat(file, '.dat');
dat.data                    = dlmread(dat.file);
dat.cons                    = dat.data(:, 5);

                                    % for component = 1:3
                                    %     switch component
                                    %         case 1
                                    %             epoch = c1;
                                    %         case 2
                                    %             epoch = c1_1;
                                    %         case 3
                                    %             epoch = c1_2;
                                    %     end
                                    % epoch = c1;
for condition = 1:3
    cfg                     = []; 
    cfg.covariance          = 'yes';
    cfg.covariancewindow    = 'all';
    cfg.vartrllength        = 2;
    switch condition
        case 1
            cfg.trials              = find(dat.cons > 2); % lower visual field
            erp_L                   = ft_timelockanalysis(cfg, c1);
        case 2
            cfg.trials              = find(dat.cons < 3); % upper visual field
            erp_U                   = ft_timelockanalysis(cfg, c1);
        case 3
            cfg.trials              = find(dat.cons < 5); % all trials
            erp_all                 = ft_timelockanalysis(cfg, c1);
    end
end

fprintf('\n\n\n FINISHED AVERAGING! \n\n\n')
end

