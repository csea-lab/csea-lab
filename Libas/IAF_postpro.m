function [CoGmat, freqs, mat_rem1of] = IAF_postpro(filemat, plotflag)

% this wants specfiles
% cd '/Users/andreaskeil/Desktop/ALPHA ANALYSIS'

figure(101)

freqs = 0:.5:100;

for fileindex = 1:size(filemat,1)

    disp(filemat(fileindex,:))
    
    disp(fileindex)
    
    filepath = deblank(filemat(fileindex,:));
    lastdotindex = max(strfind(filepath, '.')); 

    a = load(filepath);

    mat = eval(['a.' char(fieldnames(a))]);
    
    alphafreq = find(freqs >= 8 & freqs <= 12);

    mat = mat+1; % to avoid near-zero division issues when correcting for 1/f

    for chan = 1:size(mat, 1)
        [mat_rem1of(chan, :), expmod(chan,:)] = rm1overf(mat(chan,3:99), 12:26, 1); % flag toggles between 1 and  2
    end
    [CoGmat] = CoGspec(mat_rem1of(:,12:26), 6.5:.5:13.5);
 
    if plotflag
    plot(freqs(3:75), mat(19, 3:75)'), grid, hold on
    plot(freqs(3:75), expmod(19, 1:73)'), grid
    plot(freqs(3:75), mat_rem1of(19, 1:73)'),
    title([filepath '  ' num2str(CoGmat(19))])
    pause
    end
    hold off

    eval(['save ' filepath(1:lastdotindex) 'CoG.mat CoGmat -mat'])
    eval(['save ' filepath(1:lastdotindex) 'rm1f.mat mat_rem1of -mat'])
  
end