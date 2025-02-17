function [gm_trials, gm_globalbadchannel, gm_epochbadchannels] = extractartifloginfo(filepath)
% Script for extracting artifact information
% gm_trials = list of average trials per person
% gm_globalbadchannels = list of global bad channels per person
% gm_epochbadchannels = list of epoch bad channels per person

gm_trials = []

% Set up arrays, adapt name for study
data = filepath;

% Get average trials for all people
for i = 1:length(data)
    % Extract artifact log
    trials = load(data(i).name);
    trialspercond = trials.artifactlog.goodtrialsbycondition;
    trialspercond_col = trialspercond';
    gm_trials(i, :) = trialspercond_col;
end

globalchannels = zeros(1, length(data)); % global bad channels
% Get global bad channels for all people
for i = 1:length(data)
    channellog = load(data(i).name);
    globalchannels(i) = length(channellog.artifactlog.globalbadchans);
end
gm_globalbadchannel = globalchannels';

% Get epoch bad channels for all people
for i = 1:length(data)
    badchanneltriallog = load(data(i).name);
    epochbadchannels = badchanneltriallog.artifactlog.epochbadchans
    for x = 1:length(epochbadchannels)
        epochchannels = epochbadchannels{1,x};
        gm_epochbadchannels(i,x) = length(epochchannels);
    end
end
end




