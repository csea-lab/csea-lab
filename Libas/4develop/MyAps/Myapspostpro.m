% MyAps postpro script
% this runs after the prepro script generates the pup.out things

cd '/Users/csea/Documents/SarahLab/Sarah_Data/IAPs'
filemat = getfilesindir(pwd, '*bsl.mat');

% here user indicates what sample points they want to average across 
points4avg = 1500:2000; %last 1 second here; 500 sample points = 1 second;

disp(filemat)

matout4stats=[]; 

for subject=1:size(filemat,1)
        
    load(deblank(filemat(subject,:))); 
        
    data = matoutbsl(:, [1:3 5:7]); %data now excludes the two "bad" trials
        
    matout4stats(subject,:) = mean(data(points4avg, :));

end

figure
plot(mean(matout4stats(:, 1:3)), '-o')
hold on
plot(mean(matout4stats(:, 4:6)), '-o')
legend('Real', 'AI')

%Average per participant per condition
for subject=1:size(filemat,1)
    figure(1)
    plot(matout4stats(subject, 1:3),'-o')
    hold on
    pause(.5)
end
for subject=1:size(filemat,1)
    figure(2)
    plot(matout4stats(subject, 4:6),'-o')
    hold on
    pause(1)
end

% figure
% plot(matout4stats(:, 1:3), '-o')
% hold on
% plot(matout4stats(:, 4:6), '-o')
% legend('Real', 'AI')
%Write matrix into excel sheet
% T = rand(55,6)
% writetable(T,'Myaps_matout4stats.xlsx')