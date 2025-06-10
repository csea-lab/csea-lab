%% Script for analyzing all video data
% Get a list of all files and folders in the current directory
temp99 = eeglab; 

files = dir("natsounds*");

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
for subindex = 65:size(folderNames,2)

    eval(['cd ' folderNames{subindex}])

   delete *.at*

    datfile = getfilesindir(pwd, '*.dat');
    rawfile = getfilesindir(pwd, '*.RAW');

    % actual preprocessing
   LB3_prepro_pipeline(rawfile, datfile, 'getcon_natsounds', 15, {'1' '2' '3' '4'}, [-.6 6], [4  55], [3 20], 1, 'GSN-HydroCel-128.sfp', 'HC1-128.ecfg', 1); 
   % LB3_prepro_pipeline(datapath, logpath, convecfun, stringlength, conditions2select, timevec, filtercoeffHz, filtord, skiptrials, sfpfilename, ecfgfilename, eyecorrflag, DINselect)

    cd ..

    pause(.5)
    fclose('all');

end
