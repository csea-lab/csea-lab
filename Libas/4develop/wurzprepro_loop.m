function [] = wurzprepro_loop
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% raw EEG data directory
logdir = dir('/Volumes/Arash2023-4/Yannik_RawData/Rawdata/Rawdata'); 
logpath = fullfile({logdir.folder}, {logdir.name});

% raw EEG data directory
datadir = dir('/Volumes/Arash2023-4/Yannik_RawData/Rawdata/Rawdata/*.RAW');
datapath = fullfile({datadir.folder}, {datadir.name});
datapath= datapath (end-49:end)';

% raw Trigger data directory
datadir = dir('/Volumes/Arash2023-4/Yannik_RawData/Rawdata/Rawdata/*.dat');
logpath = fullfile({datadir.folder}, {datadir.name});
logpath= logpath (end-49:end)';

% loop for running through the prepro function
for n = 7:size(datapath)
    eeglab_EGI129_prepro(datapath{n}, logpath{n}, 1);
end