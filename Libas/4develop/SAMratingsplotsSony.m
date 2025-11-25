
%% first, movies
cd('/Users/andreaskeil/UFL Dropbox/Andreas Keil/SONY_UF_shared2.0/VideoData/Data');
filePaths = getfilesinfolders(pwd, 'emo', 'csv');
ratingfiles = filePaths([2:2:28 31:2:34 36:2:end],:); 

outmatratings = nan(90, 4, size(ratingfiles, 1));

warning('off')
% Collect all points and their group labels
x_all = [];
y_all = [];
grp_all = [];

for csvindex = 1:size(ratingfiles,1)
    tabledata = readtable(ratingfiles(csvindex,:));
    ratingtemp = table2array(tabledata(3:92, ["video_id","valence_id","arousal_slider_response","valence_slider_response"]));
    [moviesinorder, sortindices] = sort(ratingtemp(:,1));
    ratingtemp(:, 3:4) = (ratingtemp(:, 3:4)-5)*-1+5;
    ratingthisperson = [moviesinorder ratingtemp(sortindices,2) ratingtemp(sortindices,3) ratingtemp(sortindices,4)];
    outmatratings(:, :, csvindex) = ratingthisperson; 
end


meanratings = mean(outmatratings, 3);

% After computing meanratings
showLabels = true; % set to false to disable labels

% Colors: blue, black, red (g = 1,2,3)
colors = [0 0 1; 0 0 0; 1 0 0];

figure;
hold on;

% Offsets for label placement
rangeX = max(meanratings(:,3)) - min(meanratings(:,3));
rangeY = max(meanratings(:,4)) - min(meanratings(:,4));
dx = max(rangeX * 0.01, 1e-6);
dy = max(rangeY * 0.01, 1e-6);

for g = 1:3
    idx = (meanratings(:,2) == g);
    scatter(meanratings(idx,3), meanratings(idx,4), 60, colors(g,:), 'filled');
    
    if showLabels
        x = meanratings(idx,3);
        y = meanratings(idx,4);
        video_ids = meanratings(idx,1); % video_id labels
        labels = cellstr(num2str(video_ids)); % convert to strings
        
        % Add text labels (video_id) near each point
        text(x + dx, y + dy, labels, ...
            'FontSize', 11, 'Color', colors(g,:), ...
            'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom');
    end
end
axis([ 1 9 1 9])
hold off;
legend({'Pleasant','Neutral','Unpleasant'}, 'Location','best');
xlabel('Arousal');
ylabel('Valence');
title('Arousal vs Valence by video category');
%% now pictures
cd '/Users/andreaskeil/UFL Dropbox/Andreas Keil/SONY_UF_shared2.0/Data'
filePaths = getfilesinfolders(pwd, 'pic', 'dat');
outmatratings = []; 

filePaths = filePaths(2:2:end, :);

for datindex = 1:size(filePaths, 1)
    [ratingtemp] = getratings_MyAPS2(filePaths(datindex, :));
    [picsinorder, sortindices] = sort(ratingtemp(:,1));
    ratingtemp(:, 3) = ((ratingtemp(:, 3)-750)*-1+750)./150+1.5; % reverse scale, displeasure
    ratingtemp(:, 4) = (ratingtemp(:, 4))./150-1.5; % arousal
    ratingthisperson = [picsinorder ratingtemp(sortindices,2) ratingtemp(sortindices,4) ratingtemp(sortindices,3)];
    outmatratings(:, :, datindex) = ratingthisperson;
end

meanratings = mean(outmatratings, 3);

% After computing meanratings
showLabels = true; % set to false to disable labels

% Colors: blue, black, red (g = 1,2,3)
colors = [0 0 1; 0 0 0; 1 0 0; .5 0 1; .3 .3 .3; 1 0 .6; ];

figure;
hold on;

% Offsets for label placement
rangeX = max(meanratings(:,3)) - min(meanratings(:,3));
rangeY = max(meanratings(:,4)) - min(meanratings(:,4));
dx = max(rangeX * 0.01, 1e-6);
dy = max(rangeY * 0.01, 1e-6);

names = [11 12 13 21 22 23];

for g = 1:6
    idx = (meanratings(:,2) == names(g));
    scatter(meanratings(idx,3), meanratings(idx,4), 60, colors(g,:), 'filled');
    
    if showLabels
        x = meanratings(idx,3);
        y = meanratings(idx,4);
        video_ids = meanratings(idx,1); %  labels
        labels = cellstr(num2str(video_ids)); % convert to strings
        
        % Add text labels (video_id) near each point
        text(x + dx, y + dy, labels, ...
            'FontSize', 11, 'Color', colors(g,:), ...
            'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom');
    end
end
axis([ 1 9 1 9])
hold off;
legend({'Pleasant1','Neutral1','Unpleasant1', 'Pleasant2', 'Neutral1', 'Unpleasant2'}, 'Location','best');
xlabel('Arousal');
ylabel('Valence');
title('Arousal vs Valence by picture category');
