%% Script for analyzing all konio data

clear all

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

    logpath = getfilesindir(pwd, '*log*.dat');
    datapath = getfilesindir(pwd, '*.RAW');

    % actual preprocessing
    [EEG_allcond] = prepro_scadsandspline(datapath, logpath, 'getcon_MyAPS2_ERP', ...
        10, {'11' '12' '13' '21' '22' '23'}, [-0.6 3], 1); 

     %% select conditions
     % 21
     EEG_21 = pop_selectevent( EEG_allcond,  'type', '21' );
     EEG_21 = eeg_checkset( EEG_21 );
     % 22
     EEG_22 = pop_selectevent( EEG_allcond,  'type', '22' );
     EEG_22= eeg_checkset( EEG_22 );  
     % 23
     EEG_23 = pop_selectevent( EEG_allcond,  'type', '23' );
     EEG_23= eeg_checkset( EEG_23 );

     %% create avg reference 3-D mats
      Mat21 = avg_ref_add3d(double(EEG_21.data));
      Mat22 = avg_ref_add3d(double(EEG_22.data));
      Mat23 = avg_ref_add3d(double(EEG_23.data));
      Mat24 = avg_ref_add3d(double(EEG_24.data));

      %% compute ERPs
     ERP21 = double(avg_ref_add(squeeze(mean(EEG_21.data(:, :, skiptrials:end), 3))));
     ERP22 = double(avg_ref_add(squeeze(mean(EEG_22.data(:, :, skiptrials:end), 3))));
     ERP23 = double(avg_ref_add(squeeze(mean(EEG_23.data(:, :, skiptrials:end), 3))));
     ERP24 = double(avg_ref_add(squeeze(mean(EEG_24.data(:, :, skiptrials:end), 3)))); 

     %% save output
     % the ERPs
     SaveAvgFile([basename '.at21.ar'],ERP21,[],[], 500, [], [], [], [], 301); 
     SaveAvgFile([basename '.at22.ar'],ERP22,[],[], 500, [], [], [], [], 301); 
     SaveAvgFile([basename '.at23.ar'],ERP23,[],[], 500, [], [], [], [], 301); 
     SaveAvgFile([basename '.at24.ar'],ERP24,[],[], 500, [], [], [], [], 301); 

     % the 3d mat files
     save([basename '.trls.21.mat'], 'Mat21', '-mat')
     save([basename '.trls.22.mat'], 'Mat22', '-mat')
     save([basename '.trls.23.mat'], 'Mat23', '-mat')
     save([basename '.trls.24.mat'], 'Mat24', '-mat')


    cd ..

    pause(.5)
    fclose('all');

end
