%% Script for analyzing gaborgentone data
% Open eeglab and get a list of all files and folders in the current directory
%gives gaborgentone_PAR#.at.trls.21(22,23,24).mat
temp99 = eeglab; 

files = dir("gg*");

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
   copy_prepro_scadsandspline_log(rawfile, datfile, 'getcon_gaborgenTone', 16, {'21' '22' '23' '24'}, [-.6 3], [1  30], 4, 1)
   % prepro_scadsandspline(datapath, logpath, convecfun, stringlength, conditions2select, timevec, filtercoeffHz, filtord, skiptrials)
 

    cd ..

    pause(.5)
    fclose('all');

end
