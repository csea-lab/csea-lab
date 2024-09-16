%% Script for analyzing all konio data
cd '/Users/andreaskeil/Desktop/MyAPS2_RawData'

% Get a list of all files and folders in the current directory
files = dir("MyAPS*");

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

    logpath = getfilesindir(pwd, '*.dat');
    datapath = getfilesindir(pwd, '*.RAW');

    % actual preprocessing
    [EEG_allcond] = prepro_scadsandspline(datapath, logpath, convecfun, ...
        10, conditions2select, [-0.6 3], 1); 

    cd ..

    pause(.5)
    fclose('all');

end
