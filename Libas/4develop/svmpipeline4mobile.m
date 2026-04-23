%% start by resampling the data and making sure they are all the same
cd '/Users/andreaskeil/Desktop/olfaxis/OLDdata16chan'

filemat = getfilesindir(pwd, '*.seg.mat');

for index1 = 1:size(filemat,1)

    tmp = load(deblank(filemat(index1, :)));

    Closed_tmp = tmp.mat_end_Closed16;
    Open_tmp = tmp.mat_end_Open16;

    % resample to 500 Hz
    data_closed_ar = resample(Closed_tmp,1,2, 'Dimension', 2);
    data_open_ar = resample(Open_tmp,1,2, 'Dimension', 2);

    name_closed = [filemat(index1, 1:10) '_data_closed_ar.mat'];
    name_open = [filemat(index1, 1:10) '_data_open_ar.mat'];

    save(name_closed, 'data_closed_ar', '-mat'); 
    save(name_open, 'data_open_ar', '-mat'); 

end

%% do the FFT spectrum 
cd '/Users/andreaskeil/Desktop/olfaxis/all_Data_voltage3D'

filemat = getfilesindir(pwd, '*ar.mat');

[spec] = get_FFT_mat3d(filemat, 1:1000, 500);

%% explore the spectrum across the group
cd '/Users/andreaskeil/Desktop/olfaxis/all_Data_spectrum'

freqs = 0:0.5:100; 
filemat_spec = getfilesindir(pwd, '*.spec');

figure(101)

for index2 = 1:2:size(filemat_spec, 1)
   a = ReadAvgFile(deblank(filemat_spec(index2, :)));
   b = ReadAvgFile(deblank(filemat_spec(index2+1, :)));

   plot(freqs(1:60), a(3, 1:60)); 
   hold on
    plot(freqs(1:60), b(3, 1:60)); 
    title(deblank(filemat_spec(index2, :)))
    legend('closed', 'open')
    pause(1)
    hold off
    pause(1)
end

%% compare the groups, across eyes open and closed
% high first 
cd '/Users/andreaskeil/Desktop/olfaxis/all_Data_spectrum/Qbygroup/high'
freqs = 0:0.5:100; 
filemat_spec = getfilesindir(pwd, '*.spec');
MergeAvgFiles(filemat_spec,'GMhigh.at.spec.ar',1,1,[],0,[],[],0,0)

% low next 
cd '/Users/andreaskeil/Desktop/olfaxis/all_Data_spectrum/Qbygroup/low'
freqs = 0:0.5:100; 
filemat_spec = getfilesindir(pwd, '*.spec');
MergeAvgFiles(filemat_spec,'GMlow.at.spec.ar',1,1,[],0,[],[],0,0)

%% compare the groups, for eyes open and closed separately
% high first 
cd '/Users/andreaskeil/Desktop/olfaxis/all_Data_spectrum/Qbygroup/high'

filemat_spec = getfilesindir(pwd, '*open*.spec');
MergeAvgFiles(filemat_spec,'GMhigh.atOPEN.spec.ar',1,1,[],0,[],[],0,0)

filemat_spec = getfilesindir(pwd, '*closed*.spec');
MergeAvgFiles(filemat_spec,'GMhigh.atCLOSED.spec.ar',1,1,[],0,[],[],0,0)

pause(1)

% low next 
cd '/Users/andreaskeil/Desktop/olfaxis/all_Data_spectrum/Qbygroup/low'

filemat_spec = getfilesindir(pwd, '*open*.spec');
MergeAvgFiles(filemat_spec,'GMlow.atOPEN.spec.ar',1,1,[],0,[],[],0,0)

filemat_spec = getfilesindir(pwd, '*closed*.spec');
MergeAvgFiles(filemat_spec,'GMlow.atCLOSED.spec.ar',1,1,[],0,[],[],0,0)

%% make 4D mats for easier access and comparisons

cd '/Users/andreaskeil/Desktop/olfaxis/all_Data_spectrum/Qbygroup/low'
filemat = getfilesindir(pwd); 
[repmat] = makerepmat(filemat, 123, 2, []);
repmat_low = repmat;

cd '/Users/andreaskeil/Desktop/olfaxis/all_Data_spectrum/Qbygroup/high'
filemat = getfilesindir(pwd); 
[repmat] = makerepmat(filemat, 44, 2, []);
repmat_high = repmat;

%% now do some basic stats
[h,p,ci,stats]  = ttest2(repmat_high, repmat_low, 'dim', 3);
ttestall = stats.tstat; 
size(ttestall)
ttest_closed = squeeze(ttestall(:, :, 1, 1));
ttest_open = squeeze(ttestall(:, :, 1, 2));

SaveAvgFile('ttest_closed.at',ttest_closed,[],[], 2000,[],[],[],[],1);
SaveAvgFile('ttest_open.at',ttest_open,[],[], 2000,[],[],[],[],1);

%% now look at reactivity (closed minus open) 
reactivity_low = repmat_low(:, :, :, 1) - repmat_low(:, :, :, 2);
reactivity_high = repmat_high(:, :, :, 1) - repmat_high(:, :, :, 2);

[h,p,ci,stats]  = ttest2(reactivity_high, reactivity_low, 'dim', 3);

ttestreactivity = stats.tstat; 
size(ttestreactivity)
SaveAvgFile('ttestreactivity.at',ttestreactivity,[],[], 2000,[],[],[],[],1);

%% attempt at initial classifier
reduced_high_early = squeeze(mean(mean(reactivity_high([4 10 16], 13:20, :))));
reduced_high_late = squeeze(mean(mean(reactivity_high([4 10 16], 21:28, :)))); 

reduced_low_early = squeeze(mean(mean(reactivity_low([4 10 16], 13:20, :))));
reduced_low_late = squeeze(mean(mean(reactivity_low([4 10 16], 21:28, :)))); 

figure
plot(reduced_high_early, reduced_high_late, 'ro')
hold on 
plot(reduced_low_early, reduced_low_late, 'bo')
xlabel('early'), ylabel('late')


