%% misophonia analyses Fall 2022

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
filemat = getfilesindir(pwd, '*.mat'); 
filemat = filemat(1:2:end,:); 

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
        data = a.outmat.trialamp;
        sumamp = sumamp + mean(data,2);
    end % x
    meanSNR(:, xcon) = sumamp./(size(filematcon,1));

end % xcon

SaveAvgFile('GM59.meanslideamp.at',meanSNR,[],[], 1,[],[],[],[],1)

%% time course of single trials

cd('/Users/andreaskeil/Desktop/misophonia0822/generaudi_matfiles')
filemat = getfilesindir(pwd, '*win.mat'); 

for xcon = 1:6
    
    filematcon = filemat(xcon:6:end,:);
    
    singtrialsum = zeros(129,60);
    for x = 1:size(filematcon,1)
        a = load(deblank(filematcon(x,:)));
        data = a.outmat.fftamp;
        
        data2 = resample(data, 60, size(data,2), 'Dimension', 2); 
        singtrialsum = singtrialsum + data2;
    end % x
    
    singtrialmean(:, :, xcon) = singtrialsum./(size(filematcon,1));

end % xcon

SaveAvgFile('GM59.trialtimecourse.at1',squeeze(singtrialmean(:, 1:58, 1)),[],[], 1,[],[],[],[],1);
SaveAvgFile('GM59.trialtimecourse.at2',squeeze(singtrialmean(:, 1:58, 2)),[],[], 1,[],[],[],[],1);
SaveAvgFile('GM59.trialtimecourse.at3',squeeze(singtrialmean(:, 1:58, 3)),[],[], 1,[],[],[],[],1);
SaveAvgFile('GM59.trialtimecourse.at4',squeeze(singtrialmean(:, 1:58, 4)),[],[], 1,[],[],[],[],1);
SaveAvgFile('GM59.trialtimecourse.at5',squeeze(singtrialmean(:, 1:58, 5)),[],[], 1,[],[],[],[],1);
SaveAvgFile('GM59.trialtimecourse.at6',squeeze(singtrialmean(:, 1:58, 6)),[],[], 1,[],[],[],[],1);

%% make helpful movies 1: generalization
for x = 1:50
aha = modelFun1([0 5], -30:30).*x/50;
plot(-30:30, aha, 'r', 'linewidth', 4), axis([ -11 11 -.3 1.1]), pause(.1), flipbook(x) = getframe;
end
vidObj = VideoWriter('generalization.mp4', 'mp4');
vidObj.FrameRate = 15;
vidObj.Quality = 95;
open(vidObj) 
writeVideo(vidObj,flipbook)
%% make helpful movies 2: lateral inhibition
for x = 1:50
aha = Ricker(.1, -30:30).*x/50;
plot(-30:30, aha, 'r', 'linewidth', 4), axis([ -11 11 -.5 1.1]), pause(.1), flipbook2(x) = getframe;
end
vidObj = VideoWriter('mexhat3.mp4', 'MPEG-4');
vidObj.FrameRate = 15;
vidObj.Quality = 95;
open(vidObj) 
writeVideo(vidObj,flipbook2)