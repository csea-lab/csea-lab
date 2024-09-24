%% Script for analyzing all konio data
% Get a list of all files and folders in the current directory
files = dir("konio*");

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
   prepro_scadsandspline(rawfile, datfile, 'getcon_konio', 9, {'21' '22' '23' '24'}, [-.6 3.802], 5)

    cd ..

    pause(.5)
    fclose('all');

end
