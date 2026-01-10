% Script for analyzing all C1 from the #EEGmanylabs C1P1 clark hillyard data
%% this is the lab's pipeline
% Get a list of all files and folders in the current directory
fclose('all');
temp99 = eeglab; 

files = dir("c1*");

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

   %delete *.at*

    datfile = getfilesindir(pwd, '*Trials*.dat');
    rawfile = getfilesindir(pwd, '*.RAW');

    % actual preprocessing
   LB3_prepro_pipeline(rawfile, datfile, 'getcon_C1P1', 8, {'11' '12' '13' '14' '21' '22' '23' '24'}, [-.45 .45], [.1  30], [3 11], 1, 'GSN-HydroCel-128.sfp', 'HC1-128.ecfg',0);
   
   cd ..

    pause(.5)
    fclose('all');

end

%% this is the original Clark and Hillyard pipeline
clear

% Get a list of all files and folders in the current directory
%cd '/Users/andreaskeil/Desktop/C1P1_test/'
fclose('all')
temp99 = eeglab; 


files = dir("C19*");

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

    datfile = getfilesindir(pwd, '*Trials*.dat');
    rawfile = getfilesindir(pwd, '*.RAW');

    % actual preprocessing
   ClarkHillyardPipeline(rawfile, datfile, 'getcon_C1P1', 7, {'11' '12' '13' '14' '21' '22' '23' '24'}, [-.45 .45], [.1  45], [3 13], 1, 'GSN-HydroCel-128.sfp', 'HC1-128.ecfg',0, [100 101 107]);
   % prepro_scadsandspline_log(datapath, logpath, convecfun, stringlength, conditions2select, timevec, filtercoeffHz, filtord, skiptrials, sfpfilename, ecfgfilename)
    cd ..

    pause(.5)
    fclose('all');

end
