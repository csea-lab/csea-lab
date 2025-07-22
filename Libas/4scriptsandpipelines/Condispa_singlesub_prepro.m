%% Script for analyzing all condispa data
% Get a list of all files and folders in the current directory
temp99 = eeglab; 

cd '/Users/researchassistants/Desktop/CondiSpa'

files = dir("Rcondi*");

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
   LB3_prepro_pipeline(rawfile, datfile, 'getcon_condispa_8cons', 12, {'11' '12' '13' '14' '15' '16' '17' '18' '21' '22' '23' '24' '25' '26' '27' '28'}, [-.6 2.8], [6  32], [3 9], 1, 'GSN-HydroCel-128.sfp', 'HC1-128.ecfg', 1, []);
    % LB3_prepro_pipeline(datapath, logpath, convecfun, stringlength, conditions2select, timevec, filtercoeffHz, filtord, skiptrials, sfpfilename, ecfgfilename, eyecorrflag, DINselect)

   % prepro_scadsandspline_log(datapath, logpath, convecfun, stringlength, conditions2select, timevec, filtercoeffHz, filtord, skiptrials)
    cd ..

    pause(.5)
    fclose('all');

end
