%%
for x = 1:44, 
    a = load(deblank(filemat(x,:))); 
    pupilmat3d(:, :, x) = a.matout; 
end
plot(squeeze(mean(pupilmat3d, 3)))
%% read in MSS outside this script
% then raw correlations with no bsl for each condition

for cond = 1:6
    for time = 1:3501
     temp = corrcoef(squeeze(pupilmat3d(time, cond, :)), MSS); 
     corrmat6(time,cond) = temp(2,1); 
    end
end

%%
% now for the bsl corrected pupil

pupilmat3d_bsl = zeros(size(pupilmat3d)); 

figure
plot(squeeze(mean(pupilmat3d_bsl, 3)))

for condition = 1:6
    pupilmat3d_bsl(:, condition, :) = bslcorr(squeeze(pupilmat3d(:, condition, :))', 400:500)'; 
end

for cond = 1:6
    for time = 1:3501
     temp = corrcoef(squeeze(pupilmat3d_bsl(time, cond, :)), MSS); 
     corrmat6(time,cond) = temp(2,1); 
    end
end

figure, hold on 
for cond = 1:6
plot(corrmat6(:, cond)), pause
end
hold off

%% OK? now scatter plots
figure
for timepoint = 500:10:2500
condition = 4;
scatter(squeeze(pupilmat3d_bsl(timepoint, condition, :)), MSS, 'filled'), lsline, title(num2str(timepoint)), pause(.5), 
end

%% low and high MSS people
indexhigh = find(MSS > 12); 
indexlows = find(MSS < 12); 

figure
plot(squeeze(mean(pupilmat3d_bsl(:, :, indexhigh), 3)))
figure
plot(squeeze(mean(pupilmat3d_bsl(:, :, indexlows), 3)))

% plot in pairs
figure
for condition = 1:6
    plot(squeeze(mean(pupilmat3d_bsl(:, condition, indexhigh), 3)), 'r', 'LineWidth', 3)
    hold on
    plot(squeeze(mean(pupilmat3d_bsl(:, condition, indexlows), 3)), 'g', 'LineWidth', 3) 
    hold off
    pause
end




