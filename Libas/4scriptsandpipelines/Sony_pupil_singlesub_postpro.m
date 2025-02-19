%% Script for analyzing all rdk data
cd '/Users/andreaskeil/Desktop/Data'

% Get a list of all files and folders in the current directory
files = dir('pic*'); % start of the name

%clear output
output = []; 

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

    datfile = getfilesindir(pwd, '*log*.dat');
    edffile = getfilesindir(pwd, '*.edf');

    [matcorr, matout, matoutbsl] = eye_pipeline(edffile, 500, 'getcon_MyAPS2', datfile, 'cue_on', 500, 1500, 0);

    pause

    cd ..

    close all; 
    fclose('all'); 

end
