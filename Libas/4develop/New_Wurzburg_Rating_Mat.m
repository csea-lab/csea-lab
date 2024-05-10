pwd = '/Users/admin/Desktop/hengle/New_Wurzburg/SAM_Ratings'
filemat = getfilesindir(pwd)
for x = 1:size(filemat,1)
    [valencemat(x,:), arousalmat(x,:), shockexpmat(x,:), rewardexpmat(x,:)] = getOneWurzRating(filemat(x,:))
end

Ratings_Matrix = [valencemat; arousalmat; shockexpmat; rewardexpmat;];
writematrix(Ratings_Matrix, 'New_Wurzburg_Ratings.csv');