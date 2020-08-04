Mat
fakeEEG = rand(1,90000)';

ratings = repmat( [ 1 1 1 3 3 3 4 4 4 4 4 5 5 5 5 6 6 6 1 1 1 1 2 2 2 2 2 2 2 3], 1, 3000)';

% this is a window for the vespa (w): 
timevec = 0.002:0.002:0.6; timevec = timevec'; 

% this is the windows in ratings, cut up into slices of the vespa window's
% length, and then flipped in time
x = flipud(reshape(ratings, 300, 300)); % vespa window (w0 is 300 sample points = 600 ms, 0.6 sec :-) 

x = reshape(x, [90000, 1]);

pred = x(1:1000)*x(1:1000)';



