function [valencevec, arousalvec, shockexpvec, rewardexpvec] = getOneWurzRating(csvfile)

a = readtable(csvfile); 

% make 4 rows, suitable for collection in another variable that will be a
% spreadsheet
valencetemp = table2array(a(:, 3));
arousaltemp = table2array(a(:, 4));
shocktemp = table2array(a(:, 5));
rewardtemp = table2array(a(:, 6));


valencevec = [];
arousalvec =[];
shockexpvec =[]; 
rewardexpvec = []; 

for index = 1:5

    valencevec = [valencevec (valencetemp(index:5:end))'];
    arousalvec = [arousalvec (arousaltemp(index:5:end))'];
    shockexpvec = [shockexpvec (shocktemp(index:5:end))'];
    rewardexpvec = [rewardexpvec (rewardtemp(index:5:end))'];

end

