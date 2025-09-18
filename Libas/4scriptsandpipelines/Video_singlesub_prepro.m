%% Script for analyzing all video data
% Get a list of all files and folders in the current directory
temp99 = eeglab; 

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

% loop over subjects
for subindex = 2:size(folderNames,2)-11

    eval(['cd ' folderNames{subindex}])

   delete *.at*

    datfile = getfilesindir(pwd, '*.csv');
    datfile = deblank(datfile(1,:)); 
    rawfile = getfilesindir(pwd, '*.RAW');

    % actual preprocessing
   LB3_prepro_pipeline(rawfile, datfile, 'getcon_video', 6, {'1' '2' '3' }, [-.6 10], [3  30], [4 11], 1, 'GSN-HydroCel-256.sfp', 'HC1-256.ecfg', 1, [])

    cd ..

    pause(.5)
    fclose('all');

end
