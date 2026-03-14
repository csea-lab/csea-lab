%% Script for analyzing all video data
%% This will clear and edit your matlab path
% possibly necessary if you don't have eeglab set up correctly
clear
restoredefaultpath
gaborgenCodeRepository = '/blue/akeil/andrew.farkas/repository/gaborgen';
eeglabDirectory = '/blue/akeil/andrew.farkas/repository/eeglab2024.0';
csealabDirectory = '/blue/akeil/andrew.farkas/repository/csea-lab';
% gaborgenCodeRepository = 'C:\Users\jcedi\OneDrive\Documents\GitHub\gaborgen';
% eeglabDirectory = 'C:\Users\jcedi\OneDrive\Documents\eeglab2024.2';
cd(eeglabDirectory)
[AllEEG, ~, ~, ~] = eeglab;
cd(gaborgenCodeRepository)

% Add EMGS directory and all subdirectories to path
emegs28path = '/blue/akeil/andrew.farkas/repository/emegs2.8'; 
% emegs28path = 'C:\Users\jcedi\OneDrive\Documents\GitHub\EMEGShelper'; This should not be the EMEGShelper package, that is different than emegs2.8 
addpath(genpath(emegs28path), '-end'); 

addpath(genpath('/blue/akeil/andrew.farkas/repository/freqTag'), '-end');
% addpath(genpath('C:\Users\jcedi\OneDrive\Documents\GitHub\freqTag'), '-end');

addpath(genpath(csealabDirectory), '-end');

% Copy necessary necessary coefficient files from csea repository to EMEGS
% 2.8
copyfile([csealabDirectory filesep 'Libas' filesep 'CsdScalpLeg_15_0_5001'], [emegs28path filesep 'emegs3dCoeff40' filesep 'CsdScalpLeg_15_0_5001'])
copyfile([csealabDirectory filesep 'Libas' filesep 'ScalpLeg_15_0_5001'], [emegs28path filesep 'emegs3dCoeff40' filesep 'ScalpLeg_15_0_5001'])

%% Process run 1 for no sound participants
% data directory
dataDirectory = '/blue/akeil/andrew.farkas/data/emoclips_eeg/no_sound';

% Get a list of all files and folders in the current directory
cd(dataDirectory);
files = dir("emo*");

% Filter out the non-folder entries
dirFlags = [files.isdir];

% Extract the names of the folders
folderNames = {files(dirFlags).name};

% Remove the '.' and '..' folders
folderNames = folderNames(~ismember(folderNames, {'.', '..'}));

% Display the folder names
disp('Folders in the current working directory:');
disp(folderNames);


for subindex = 1:size(folderNames,2)

    
    % sometimes there are two log files, one for each run.
    % this handles the 1 vs 2 log file edge cases
    datfilepathExists = 0;
    datfile = getfilesindir([dataDirectory filesep folderNames{subindex} filesep 'eeg_log'], '*.csv');
    if isempty(datfile)
        datfile = getfilesindir([dataDirectory filesep folderNames{subindex} filesep 'eeg_log' filesep 'run1'], '*.csv');
        datfile = deblank(datfile(1,:));
        datfilepath = [dataDirectory filesep folderNames{subindex} filesep 'eeg_log' filesep 'run1' filesep datfile];
        datfilepathExists = 1;
    end
    if ~datfilepathExists
        datfile = deblank(datfile(1,:));
        datfilepath = [dataDirectory filesep folderNames{subindex} filesep 'eeg_log' filesep datfile];
        datfilepathExists = 1;
    end

    eval(['cd ' dataDirectory filesep folderNames{subindex} filesep 'EEG' filesep 'run1']);
    delete *.at*

    rawfile = getfilesindir(pwd, '*.RAW');


    % actual preprocessing
    % LB3_prepro_pipeline(datapath, logpath, convecfun, stringlength, conditions2select, timevec, filtercoeffHz, filtord, skiptrials, sfpfilename, ecfgfilename, eyecorrflag, DINselect)
    % LB3_prepro_pipeline(rawfile,  datfilepath, 'getcon_video', 6, {'all'}, [-.6 10], [3  40], [4 11], 1, 'GSN-HydroCel-256.sfp', 'HC1-256.ecfg', 1, [])
    LB3_prepro_pipeline(rawfile,  datfilepath, 'getcon_video_by_trial', 6, {'all'}, [-.6 10], [3  40], [4 11], 1, 'GSN-HydroCel-256.sfp', 'HC1-256.ecfg', 1, [])

    cd ..

    pause(.5)
    fclose('all');
end

%% Process run 2 for no sound participants
% data directory
dataDirectory = '/blue/akeil/andrew.farkas/data/emoclips_eeg/no_sound';

% Get a list of all files and folders in the current directory
cd(dataDirectory);
files = dir("emo*");

% Filter out the non-folder entries
dirFlags = [files.isdir];

% Extract the names of the folders
folderNames = {files(dirFlags).name};

% Remove the '.' and '..' folders
folderNames = folderNames(~ismember(folderNames, {'.', '..'}));

% Display the folder names
disp('Folders in the current working directory:');
disp(folderNames);


for subindex = 1:size(folderNames,2)

    
    % sometimes there are two log files, one for each run.
    % this handles the 1 vs 2 log file edge cases
    datfilepathExists = 0;
    datfile = getfilesindir([dataDirectory filesep folderNames{subindex} filesep 'eeg_log'], '*.csv');
    if isempty(datfile)
        datfile = getfilesindir([dataDirectory filesep folderNames{subindex} filesep 'eeg_log' filesep 'run2'], '*.csv');
        datfile = deblank(datfile(1,:));
        datfilepath = [dataDirectory filesep folderNames{subindex} filesep 'eeg_log' filesep 'run2' filesep datfile];
        datfilepathExists = 1;
        onlyOneLog = 0;
    end
    if ~datfilepathExists
        datfile = deblank(datfile(1,:));
        datfilepath = [dataDirectory filesep folderNames{subindex} filesep 'eeg_log' filesep datfile];
        datfilepathExists = 1;
        onlyOneLog = 1;
    end

    eval(['cd ' dataDirectory filesep folderNames{subindex} filesep 'EEG' filesep 'run2']);
    delete *.at*

    rawfile = getfilesindir(pwd, '*.RAW');


    % actual preprocessing
    % LB3_prepro_pipeline(datapath, logpath, convecfun, stringlength, conditions2select, timevec, filtercoeffHz, filtord, skiptrials, sfpfilename, ecfgfilename, eyecorrflag, DINselect)
    % if onlyOneLog
    %     LB3_prepro_pipeline(rawfile,  datfilepath, 'getcon_video_run2', 6, {'all'}, [-.6 10], [3  40], [4 11], 1, 'GSN-HydroCel-256.sfp', 'HC1-256.ecfg', 1, [])
    % else 
    %     LB3_prepro_pipeline(rawfile,  datfilepath, 'getcon_video', 6, {'all'}, [-.6 10], [3  40], [4 11], 1, 'GSN-HydroCel-256.sfp', 'HC1-256.ecfg', 1, [])
    % end
    if onlyOneLog
        LB3_prepro_pipeline(rawfile,  datfilepath, 'getcon_video_by_trial_run2', 6, {'all'}, [-.6 10], [3  40], [4 11], 1, 'GSN-HydroCel-256.sfp', 'HC1-256.ecfg', 1, [])
    else 
        LB3_prepro_pipeline(rawfile,  datfilepath, 'getcon_video_by_trial', 6, {'all'}, [-.6 10], [3  40], [4 11], 1, 'GSN-HydroCel-256.sfp', 'HC1-256.ecfg', 1, [])
    end


    cd ..

    pause(.5)
    fclose('all');
end


%% Process run 1 for sound participants
% data directory
dataDirectory = '/blue/akeil/andrew.farkas/data/emoclips_eeg/sound';

% Get a list of all files and folders in the current directory
cd(dataDirectory);
files = dir("ema*");

% Filter out the non-folder entries
dirFlags = [files.isdir];

% Extract the names of the folders
folderNames = {files(dirFlags).name};

% Remove the '.' and '..' folders
folderNames = folderNames(~ismember(folderNames, {'.', '..'}));

% Display the folder names
disp('Folders in the current working directory:');
disp(folderNames);


for subindex = 1:size(folderNames,2)

    
    % sometimes there are two log files, one for each run.
    % this handles the 1 vs 2 log file edge cases
    datfilepathExists = 0;
    datfile = getfilesindir([dataDirectory filesep folderNames{subindex} filesep 'eeg_log'], '*.csv');
    if isempty(datfile)
        datfile = getfilesindir([dataDirectory filesep folderNames{subindex} filesep 'eeg_log' filesep 'run1'], '*.csv');
        datfile = deblank(datfile(1,:));
        datfilepath = [dataDirectory filesep folderNames{subindex} filesep 'eeg_log' filesep 'run1' filesep datfile];
        datfilepathExists = 1;
    end
    if ~datfilepathExists
        datfile = deblank(datfile(1,:));
        datfilepath = [dataDirectory filesep folderNames{subindex} filesep 'eeg_log' filesep datfile];
        datfilepathExists = 1;
    end

    eval(['cd ' dataDirectory filesep folderNames{subindex} filesep 'EEG' filesep 'run1']);
    delete *.at*

    rawfile = getfilesindir(pwd, '*.RAW');


    % actual preprocessing
    % LB3_prepro_pipeline(datapath, logpath, convecfun, stringlength, conditions2select, timevec, filtercoeffHz, filtord, skiptrials, sfpfilename, ecfgfilename, eyecorrflag, DINselect)
    % LB3_prepro_pipeline(rawfile,  datfilepath, 'getcon_video', 6, {'all'}, [-.6 10], [3  40], [4 11], 1, 'GSN-HydroCel-256.sfp', 'HC1-256.ecfg', 1, [])
    LB3_prepro_pipeline(rawfile,  datfilepath, 'getcon_video_by_trial', 6, {'all'}, [-.6 10], [3  40], [4 11], 1, 'GSN-HydroCel-256.sfp', 'HC1-256.ecfg', 1, [])

    cd ..

    pause(.5)
    fclose('all');
end

%% Process run 2 for sound participants
% data directory
dataDirectory = '/blue/akeil/andrew.farkas/data/emoclips_eeg/sound';

% Get a list of all files and folders in the current directory
cd(dataDirectory);
files = dir("ema*");

% Filter out the non-folder entries
dirFlags = [files.isdir];

% Extract the names of the folders
folderNames = {files(dirFlags).name};

% Remove the '.' and '..' folders
folderNames = folderNames(~ismember(folderNames, {'.', '..'}));

% Display the folder names
disp('Folders in the current working directory:');
disp(folderNames);


for subindex = 1:size(folderNames,2)

    
    % sometimes there are two log files, one for each run.
    % this handles the 1 vs 2 log file edge cases
    datfilepathExists = 0;
    datfile = getfilesindir([dataDirectory filesep folderNames{subindex} filesep 'eeg_log'], '*.csv');
    if isempty(datfile)
        datfile = getfilesindir([dataDirectory filesep folderNames{subindex} filesep 'eeg_log' filesep 'run2'], '*.csv');
        datfile = deblank(datfile(1,:));
        datfilepath = [dataDirectory filesep folderNames{subindex} filesep 'eeg_log' filesep 'run2' filesep datfile];
        datfilepathExists = 1;
        onlyOneLog = 0;
    end
    if ~datfilepathExists
        datfile = deblank(datfile(1,:));
        datfilepath = [dataDirectory filesep folderNames{subindex} filesep 'eeg_log' filesep datfile];
        datfilepathExists = 1;
        onlyOneLog = 1;
    end

    eval(['cd ' dataDirectory filesep folderNames{subindex} filesep 'EEG' filesep 'run2']);
    delete *.at*

    rawfile = getfilesindir(pwd, '*.RAW');


    % actual preprocessing
    % LB3_prepro_pipeline(datapath, logpath, convecfun, stringlength, conditions2select, timevec, filtercoeffHz, filtord, skiptrials, sfpfilename, ecfgfilename, eyecorrflag, DINselect)
    % if onlyOneLog
    %     LB3_prepro_pipeline(rawfile,  datfilepath, 'getcon_video_run2', 6, {'all'}, [-.6 10], [3  40], [4 11], 1, 'GSN-HydroCel-256.sfp', 'HC1-256.ecfg', 1, [])
    % else 
    %     LB3_prepro_pipeline(rawfile,  datfilepath, 'getcon_video', 6, {'all'}, [-.6 10], [3  40], [4 11], 1, 'GSN-HydroCel-256.sfp', 'HC1-256.ecfg', 1, [])
    % end
    if onlyOneLog
        LB3_prepro_pipeline(rawfile,  datfilepath, 'getcon_video_by_trial_run2', 6, {'all'}, [-.6 10], [3  40], [4 11], 1, 'GSN-HydroCel-256.sfp', 'HC1-256.ecfg', 1, [])
    else 
        LB3_prepro_pipeline(rawfile,  datfilepath, 'getcon_video_by_trial', 6, {'all'}, [-.6 10], [3  40], [4 11], 1, 'GSN-HydroCel-256.sfp', 'HC1-256.ecfg', 1, [])
    end


    cd ..

    pause(.5)
    fclose('all');
end


