%% Script for analyzing all MyAPS2 data

clear;

% 1 runs single trials (individual scenes), 0 does by category
singleTrial = 0;


% List of potential directories, add yours if you want this to run on your
% computer
directories = {
    '/Users/andreaskeil/Desktop/MyAPS2_RawData', ...
    '/home/andrewf/Research_data/EEG/MyAPS/MyAPS2/Data'
};

% Check which directories exist
existingDirs = directories(cellfun(@isfolder, directories));

% Stop if more than one directory matches
if length(existingDirs) > 1
    error('Multiple matching directories found. Please ensure only one directory is available.');
elif isempty(existingDirs)
    error('None of the listed directories exist. Please check your paths.');
else
    rawDataDir = existingDirs{1};
    cd(rawDataDir);
end


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

    logpath = getfilesindir(pwd, '*log*.dat');
    datapath = getfilesindir(pwd, '*.RAW');

    getConArguments{1} = logpath;

     % actual preprocessing
     % [EEG_allcond] =  prepro_scadsandspline(datapath, getConArguments, convecfun, stringlength, conditions2select, timevec, filtercoeffHz, filtord, skiptrials, baselineStartStopMs)
    if singleTrial
        getConArguments{2} = singleTrial;
        conditions2select = {'all'};
        [EEG_allcond] = prepro_scadsandspline(datapath, getConArguments, 'getcon_MyAPS2_ERP', ...
            10, conditions2select, [-0.2 1], [.1 40], 3, 1, 'none');
    else
        [EEG_allcond] = prepro_scadsandspline(datapath, getConArguments, 'getcon_MyAPS2_ERP', ...
            10, {'11' '12' '13' '21' '22' '23'}, [-0.6 2], [.2 20], 3, 1);
    end

   

    cd ..

    pause(.5)
    fclose('all');

end
