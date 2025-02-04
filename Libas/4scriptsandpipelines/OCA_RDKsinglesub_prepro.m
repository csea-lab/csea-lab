%% Script for analyzing all OCA RDK data
% Get a list of all files and folders in the current directory
temp99 = eeglab; 

cd '/Volumes/G-RAID Thunderbolt 3/OCA_project/OCA_RDK'

files = dir("RDK*");

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
for subindex = 30:size(folderNames,2)

    eval(['cd ' folderNames{subindex}])

   delete *.at*

    datfile = getfilesindir(pwd, '*.dat');
    rawfile = getfilesindir(pwd, '*.RAW');

    % actual preprocessing
   LB3_prepro_pipeline(rawfile, datfile, 'getcon_COARD_RDK', 12, {'1' '2' '3' '4'}, [-.6 9], [3  30], [4 9], 1, 'GSN-HydroCel-256.sfp', 'HC1-256.ecfg', 1);
  %  LB3_prepro_pipeline(datapath, logpath, convecfun, stringlength, conditions2select, timevec, filtercoeffHz, filtord, skiptrials, sfpfilename, ecfgfilename, eyecorrflag)

    cd ..

    pause(.5)
    fclose('all');

end
