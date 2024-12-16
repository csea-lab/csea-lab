%% Script for analyzing New Wurzburg EEG data
clear
% Get a list of all files and folders in the current directory
temp99 = eeglab; 

cd '/Volumes/TOSHIBA EXT/New_Wurzburg/Data/one_event_marker/'

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

    delete *.at*
    
    rawfile = getfilesindir(pwd, '*.RAW');
    tempmat = getfilesindir(pwd, '*.csv');
    datfile = deblank(tempmat(1,:));

    % actual preprocessing
   prepro_scadsandspline_log(rawfile, datfile, 'getCon_NewWurz', 12, {'1' '2' '3' '4' '5' }, [-.8 7], [3  32], [4  9], 3, 'GSN-HydroCel-128.sfp', 'HC1-128.ecfg');
   % prepro_scadsandspline_log(datapath, logpath, convecfun, stringlength, conditions2select, timevec, filtercoeffHz, filtord, skiptrials)
    cd ..

    pause(.5)
    fclose('all');

end
