close all; clearvars;

%Set directory - location of subject files folders
DIR = '/Users/katemccain/Documents/video_alpha/Konio';

%List of subjects to process, based on the name of the folder that contains that subject's data
SUB = {'konio_401'};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Loop through each subject listed in SUB
for i = 1:length(SUB)

    % Clear temp for each iteration
    temp = [];

    %Define subject 
    Subject_Path = ([DIR filesep 'Data' filesep SUB{i}]);

    % Create a search pattern '.dat' file
    search_dat = fullfile(Subject_Path, '*.dat');

    % Use the dir function - identify .dat files
    dat_file = dir(searchPattern);

    % Extract conditions from .dat file
    temp = getcon_konio([Subject_Path filesep dat_file.name]);
    
    % Create a search pattern '.CON' file
    searchCON = fullfile(Subject_Path, '*.CON');
    
    % Use the dir function - identify .CON file
    con_file = dir(searchCON);

    % Define the original file path
    originalFilePath = [Subject_Path con_file.name]; 

    % Open Subject_Path for overwriting .CON file with extracted condiitons from .dat file
    fid = fopen(originalFilePath, 'wt');  % 'wt' clears file 
    
    % Write the header row for .CON file
    fprintf(fid, '%d,%d\n', 160, 1);
    
    % Write the data from 'temp' (conditions) into .CON file
    for row = 1:size(temp, 1)
        fprintf(fid, '%f', temp(row, 1));
        for col = 2:size(temp, 2)
            fprintf(fid, ',%f', temp(row, col));
        end
        fprintf(fid, '\n'); 
    end
    
    % Close the original file
    fclose(fid);    

    % EMEGS takes con files with the lowercase extension '.con' but MATLAB doesn't let you rename it from upper to lower case directly
    temp_file_name = [(:,1:end -3) 'txt'];
    new_file_name = [originalFilePath(:,1:end -3) 'con'];

    % movefile moves the txt file into subject folder, so .con can be added
    movefile(originalFilePath, temp_file_name);
    movefile(temp_file_name, new_file_name);
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