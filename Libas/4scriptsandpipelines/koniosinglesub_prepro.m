% Get a list of all files and folders in the current directory
files = dir;
%% Script for analyzing all konio data
% Filter out the non-folder entries
dirFlags = [files.isdir];

% Extract the names of the folders
folderNames = {files(dirFlags).name};

% Remove the '.' and '..' folders
folderNames = folderNames(~ismember(folderNames, {'.', '..'}));

% Display the folder names
disp('Folders in the current working directory:');
disp(folderNames);

% info for spectrum
spectime = 801:2200; 
Fbin  = 22; 
Hbin = 43; 

% axes for plots: 
% faxis=  0:0.3125:125;  % for 601:2200
faxis=  0:1000/2800:125;  % for 801:2200
taxis= -600:2:3800; 

% loop pver subjects
for subindex = 1:size(folderNames,2)

    eval(['cd ' folderNames{subindex}])

   delete *.at*

    datfile = getfilesindir(pwd, '*.dat');
    rawfile = getfilesindir(pwd, '*.RAW');

    % actual preprocessing
    [EEG_allcond] =  prepro_scadsandspline(rawfile, datfile, 9);

    cd ..

    pause(1)
    fclose('all');

end
