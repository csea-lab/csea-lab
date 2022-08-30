% misophonia analyses Fall 2022

%% first establish the tagging frequency was as expected, from the mat files

cd('/Users/andreaskeil/Desktop/misophonia0822/generaudi_matfiles')
filemat = getfilesindir(pwd); 

sumspec = zeros(129, 2500); % initialize mean spectrum with 5000 points (2500 till nyquist)
for x = 1:size(filemat,1)
    a = load(deblank(filemat(x,:))); 
    data = mean(a.outmat,3); 
    fprintf('.')
    if x/10 == round(x/10), disp(x), end
    [tempspecevoked, phase, freqs] = FFT_spectrum([data(:, 301:1800) zeros(129, 3500)], 500); % zero padding for .1 Hz res
    sumspec = sumspec+ tempspecevoked; 
end
plot(freqs(205:500), sumspec(:, 205:500)')
xline(41.2)
SaveAvgFile('GM59.evoked.at.spec',sumspec,[],[], 10000,[],[],[],[],1)
% OK that worked well, it is exactly at 41.2 Hz. Now to the slide win
%% compute the sliding window stuff
cd('/Users/andreaskeil/Desktop/misophonia0822/generaudi_matfiles')
filemat = getfilesindir(pwd, '*.app??mat'); 

for x = 1:size(filemat,1)
    a = load(deblank(filemat(x,:))); 
    data = a.outmat; 
    [trialamp,winmat3d,phasestabmat,trialSNR] = flex_slidewin(data, 0, 200:300, 551:1800 , 41.2, 600, 500, deblank(filemat(x,:)));
end
%% look at the sliding window stuff
cd('/Users/andreaskeil/Desktop/misophonia0822/generaudi_matfiles')
filemat = getfilesindir(pwd, '*win.mat'); 

for xcon = 1:6
    
    filematcon = filemat(xcon:6:end,:);
    
    sumamp = zeros(129,1);
    for x = 1:size(filematcon,1)
        a = load(deblank(filematcon(x,:)));
        data = a.outmat.fftamp;
        sumamp = sumamp + mean(data,2);
    end % x
    meanamp(:, xcon) = sumamp./(size(filematcon,1));

end % xcon


