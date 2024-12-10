pwd = '/Volumes/TOSHIBA EXT/New_Wurzburg/Analyses/Indivdual SAM Ratings'
filemat = getfilesindir(pwd, '*Sam*')

subject_numbers = [];
for x = 1:size(filemat,1)
    [~, filename, ~] = fileparts(filemat(x, :));
    subject_number = filename(10:12);
    subject_numbers = [subject_numbers, str2double(subject_number)];
    [valencemat(x,:), arousalmat(x,:), shockexpmat(x,:), rewardexpmat(x,:)] = getOneWurzRating(filemat(x,:));
end

valence_matrix = [subject_numbers', valencemat];
arousal_matrix = [subject_numbers', arousalmat];
shock_expectancy_matrix = [subject_numbers', shockexpmat];
reward_expectancy_matrix = [subject_numbers', rewardexpmat];

Ratings_Matrix = [valence_matrix; arousal_matrix; shock_expectancy_matrix; reward_expectancy_matrix;];
writematrix(Ratings_Matrix, 'New_Wurzburg_Ratings.csv')
readmatrix('New_Wurzburg_Ratings.csv')