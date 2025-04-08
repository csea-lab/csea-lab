%% Script for analyzing New Wurzburg EEG data
clear
restoredefaultpath

addpath('/Users/admin/Documents/GitHub/csea-lab/Libas', '-end');

addpath('/Users/admin/Documents/GitHub/csea-lab/Libas/4develop', '-end');

addpath('/Users/admin/Documents/GitHub/csea-lab/Libas/4wavelettrans', '-end');

addpath('/Users/admin/Documents/GitHub/csea-lab/Libas/4scriptsandpipelines', '-end');

addpath(genpath('/Users/admin/Documents/GitHub/csea-lab/Libas/4data'), '-end');

addpath('/Users/admin/Documents/eeglab2024.0', '-end');

temp99 = eeglab;

addpath(genpath('/Users/admin/Documents/emegs2.8'), '-end');



% /Users/admin/Documents/GitHub/freqTag maybe add in later
% 


% Get a list of all files and folders in the current directory

cd '/Volumes/TOSHIBA_EXT/New_Wurzburg/Data'

files = dir("new_*");

% Filter out the non-folder entries
dirFlags = [files.isdir];

% Extract the names of the folders
folderNames = {files(dirFlags).name};

% Remove the '.' and '..' folders
folderNames = folderNames(~ismember(folderNames, {'.', '..'}));

% Display the folder names
disp('Folders in the current working directory:');
disp(folderNames);

% loop over subjects
for subindex = 1:size(folderNames,2)

    eval(['cd ' folderNames{subindex}])

    % delete *.at*

    rawfile = getfilesindir(pwd, '*.RAW');
    tempmat = getfilesindir(pwd, '*.csv');
    datfile = deblank(tempmat(1,:));

    current_folder = folderNames{subindex};

    current_participant = regexp(current_folder, '\d+', 'match');

    current_participant = str2num(current_participant{1});

    % triggers missing, maybe recover the trials from these participant
    % later
    if ismember(current_participant, [201, 202, 209, 211, 213])
        cd ..
        continue
    end

    % actual preprocessing
    if current_participant < 226
        prepro_scadsandspline_log(rawfile, datfile, 'getCon_newWurz_singleTrial', 12, {'all'}, [-.8 7], [3  32], [4  9], 3, 'GSN-HydroCel-128.sfp', 'HC1-128.ecfg');
    else
        prepro_scadsandspline_log(rawfile, datfile, 'getCon_newWurz_singleTrial_2trigs', 12, {'11' '12' '13' '14' '15' }, [9 .8], [3  32], [4  9], 3, 'GSN-HydroCel-128.sfp', 'HC1-128.ecfg');
    end



    % prepro_scadsandspline_log(datapath, logpath, convecfun, stringlength, conditions2select, timevec, filtercoeffHz, filtord, skiptrials)
    cd ..

    pause(.5)
    fclose('all');
end
