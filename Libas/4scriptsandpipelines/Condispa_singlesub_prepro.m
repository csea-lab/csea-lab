%% Script for analyzing all condispa data
% Get a list of all files and folders in the current directory
temp99 = eeglab; 

files = dir("condi*");

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

    datfile = getfilesindir(pwd, '*.dat');
    rawfile = getfilesindir(pwd, '*.RAW');

    % actual preprocessing
   prepro_scadsandspline_log(rawfile, datfile, 'getcon_condispa1', 12, {'1' '2' '3' '4' '5' '6'}, [-.4 2.8], [3  32], 6, 1, 'GSN-HydroCel-128.sfp', 'HC1-128.ecfg');
   prepro_scadsandspline_log(rawfile, datfile, 'getcon_condispa2', 12, {'7' '8' '9' '10' '11' '12'}, [-.4 2.8], [3  32], 6, 1, 'GSN-HydroCel-128.sfp', 'HC1-128.ecfg');

   % prepro_scadsandspline_log(datapath, logpath, convecfun, stringlength, conditions2select, timevec, filtercoeffHz, filtord, skiptrials)
    cd ..

    pause(.5)
    fclose('all');

end
