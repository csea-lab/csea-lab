function [expectancy, responsetime] = konioratings(filemat)
% reads a rating.txt file from the konio study and makes a spreadsheet
% 
% Initial list of files including '.DS_Store'
filemat = [
    'konioRating_401.txt',
    'konioRating_402.txt',
    'konioRating_404.txt',
    'konioRating_405.txt',
    'konioRating_406.txt',
    'konioRating_407.txt',
    'konioRating_408.txt',
    'konioRating_409.txt',
    'konioRating_410.txt',
    'konioRating_414.txt',
    'konioRating_415.txt',
    'konioRating_416.txt'
];

for index = 1:size(filemat,1)

fid = fopen(filemat(index,:)); 

line1 = fgetl(fid);
line2 = fgetl(fid);

expectancy(index,:) = str2num(line1); 
responsetime(index,:) = str2num(line2);

end


% Calculate the mean of each of the 16 columns
meanExpectancy = mean(expectancy);

% Create a bar plot of the mean expectancy
b = bar(meanExpectancy, 'FaceColor', 'flat'); % Enables individual bar color customization

% Define the colors
black = [0, 0, 0]; % Black
yellow = [255, 255, 0] / 255; % Yellow

% Initialize an empty array for colors
colors = zeros(length(meanExpectancy), 3);

% Apply the colors in a pattern (first two black, next two yellow, and so on)
for i = 1:length(meanExpectancy)
    if mod(floor((i-1)/2), 2) == 0
        colors(i, :) = black; % Apply black for the first pattern
    else
        colors(i, :) = yellow; % Apply yellow for the next pattern
    end
end

% Apply the colors to the bars
for i = 1:length(meanExpectancy)
    b.CData(i, :) = colors(i, :);
end

% Optional: Add labels and title for clarity
xlabel('Column Index');
ylabel('Mean Value');
title('Mean Value of Each Column in Expectancy');
