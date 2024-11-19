close all; clearvars;

%Set directory - location of subject files folders
konio_files = '/Users/katemccain/Documents/Konio';

%List of subjects to process, based on the name of the folder that contains that subject's data
SUB = {'konio_417', 'konio_418', 'konio_419'};
% SUB = {'konio_401', 'konio_402', 'konio_405', 'konio_406', 'konio_407', 'konio_408'...
%         'konio_409', 'konio_410', 'konio_414','konio_415','konio_416'};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Loop through each subject listed in SUB
for i = 1:length(SUB)

    % Clear temp for each iteration
    temp = [];

    %Define subject 
    DIR = ([konio_files filesep 'Data' filesep SUB{i}]);
    
    eval(['cd ' DIR])

    pwd
    dattemp = dir('**/*.dat');

    contemp = dir('**/*fl40h5.E1.CON');

    % Extract conditions from .dat file
    temp_dat = getcon_konio(dattemp.name);
    
    % Define the original file path
    originalFilePath = [contemp.name]; 
    
    % copy con file into.old version
    copyfile(originalFilePath, [originalFilePath '.OLD'])

    pause(.5)

    % now delete the old con file
    delete(originalFilePath)

    % Open Subject_Path for overwriting .CON file with extracted condiitons from .dat file
    fid = fopen(originalFilePath, 'wt');  % 'wt' clears file 
    
    % Write the header row for .CON file
    fprintf(fid, '%d %d\n', 160, 1);
    
    % Write the data from 'temp' (conditions) into .CON file
    for row = 1:size(temp_dat, 1)
        fprintf(fid, '%f', temp_dat(row, 1));
        for col = 2:size(temp_dat, 2)
            fprintf(fid, ',%f', temp_dat(row, col));
        end
        fprintf(fid, '\n'); 
    end
    
    % Close the original file
    fclose(fid);    

%     % EMEGS takes con files with the lowercase extension '.con' but MATLAB doesn't let you rename it from upper to lower case directly
%     temp_file_name = [(:,1:end -3) 'txt'];
%     new_file_name = [originalFilePath(:,1:end -3) 'con'];
% 
%     % movefile moves the txt file into subject folder, so .con can be added
%     movefile(originalFilePath, temp_file_name);
%     movefile(temp_file_name, new_file_name);
end


function [convec] = getcon_konio(datfilepath)
% This little piece of code opens a dat file form the 2024 konio study with
% gratings, reads it, outputs a condition vector - should be 160 elements

temp = load(datfilepath);

convec = temp(:, 2)*10 + temp(:, 6);

if length(convec) ~= 160
    disp('warning: not 160')
end

end