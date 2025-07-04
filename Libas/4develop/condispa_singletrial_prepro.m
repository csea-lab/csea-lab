%% Script for analyzing condispa data by single trial
% Get a list of all files and folders in the current directory
temp99 = eeglab; 

cd = '/Volumes/TOSHIBA_EXT/CondiSpa/OG_Data';
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
for subindex = 3:size(folderNames,2)

    eval(['cd ' folderNames{subindex}])

   % delete *.at*

    datfile = getfilesindir(pwd, '*.dat');
    rawfile = getfilesindir(pwd, '*.RAW');

    % actual preprocessing
   LB3_prepro_pipeline(rawfile, datfile, 'get_condispas', 13, {'101', '102', '103', '201', '202', '203'}, [-.8 2], [3 40], [3 8], 1, 'GSN-HydroCel-128.sfp', 'HC1-128.ecfg', 1, 'DIN4');
   
   % prepro_scadsandspline_log(datapath, logpath, convecfun, stringlength, conditions2select, timevec, filtercoeffHz, filtord, skiptrials)
    cd ..

    pause(.5)
    fclose('all');

end
