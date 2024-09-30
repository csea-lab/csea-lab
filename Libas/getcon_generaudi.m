function [convec] = getcon_generaudi(datfilepath)

% Function to open the event/log files (.dat) and extracted. 11, 12, 13 
% (CS+, GS1, GS2 in habituation); 24, 25, 26 (CS+, GS1, GS2 in acquisition)
% this function was created with help from ChatGPT on June, 5, 2024


fileID = fopen(datfilepath, 'r');

% Initialize an empty vector to store the extracted numbers
newVector = [];

% Read the file line by line
line = fgetl(fileID);
while ischar(line)
    % Split the line into columns
    columns = str2double(strsplit(line));
    
    % Check if the line has at least 4 columns
    if length(columns) >= 4
        % Extract the numbers from the second and fourth columns
        newVector(end+1, 1) = columns(2); % Second column
        newVector(end, 2) = columns(4);   % Fourth column
    end
    
    % Read the next line
    line = fgetl(fileID);
end

% Close the file
fclose(fileID);

% Combine the numbers into a single vector
%resultVector = reshape(newVector', [], 1);
convec = newVector(:,1).*10 + newVector(:,2);

end