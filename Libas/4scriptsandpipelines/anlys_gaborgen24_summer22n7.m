%% gaborgn24 sep 2nd 22
%% 
%% first average all mats
cd('/Users/andreaskeil/Desktop/gaborgen24_summer22/appandmat/Gaborgen24_pilot200_appFiles')
filemat = getfilesindir(pwd, '*.mat'); 

sumtime = zeros(129, 1101); % initialize mean spectrum with 5000 points (2500 till nyquist)
for x = 1:size(filemat,1)
    a = load(deblank(filemat(x,:))); 
    data = mean(a.outmat,3); 
    fprintf('.')
    if x/10 == round(x/10), disp(x), end
    sumtime = sumtime+ data; 
end


%% compute sliding window stuff
cd('/Users/andreaskeil/Desktop/gaborgen24_summer22/appandmat/Gaborgen24_pilot200_appFiles')
filemat = getfilesindir(pwd, '*.mat'); 

for x = 1:size(filemat,1)
    a = load(deblank(filemat(x,:))); 
    data = a.outmat;   
   [trialamp,winmat3d,phasestabmat,trialSNR] = freqtag_slidewin(data, 0, 50:100, 301:1100, 15, 600, 500, deblank(filemat(x,:))) ;  
end


%% look at the mean sliding window stuff for acquisition
cd('/Users/andreaskeil/Desktop/gaborgen24_summer22/appandmat/acquisition')
filemat = getfilesindir(pwd, '*win.mat'); 

for xcon = 1:5
    
    filematcon = filemat(xcon:5:end,:);
    
    sumamp = zeros(129,1);
    for x = 1:size(filematcon,1)
        a = load(deblank(filematcon(x,:)));
        data = a.outmat.fftamp;
        sumamp = sumamp + mean(data,2);
    end % x
    meantrialamp(:, xcon) = sumamp./(size(filematcon,1));

end % xcon

SaveAvgFile('GM7.meanslideamp.at',meantrialamp,[],[], 1,[],[],[],[],1)

%% time course of single trials

cd('/Users/andreaskeil/Desktop/gaborgen24_summer22/appandmat/acquisition')
filemat = getfilesindir(pwd, '*win.mat'); 

singtrialmean = []; 

for xcon = 1:5
    
    filematcon = filemat(xcon:5:end,:);
    
    singtrialsum = zeros(129,30);
    for x = 1:size(filematcon,1)
        a = load(deblank(filematcon(x,:)));
        data = a.outmat.fftamp;        
        data2 = resample(data, 30, size(data,2), 'Dimension', 2); 
        singtrialsum = singtrialsum + data2;
    end % x
    
    singtrialmean(:, :, xcon) = singtrialsum./(size(filematcon,1));

end % xcon

SaveAvgFile('GM7.trialtimecourse.at1',squeeze(singtrialmean(:, 1:end-2, 1)),[],[], 1,[],[],[],[],1);
SaveAvgFile('GM7.trialtimecourse.at2',squeeze(singtrialmean(:, 1:end-2, 2)),[],[], 1,[],[],[],[],1);
SaveAvgFile('GM7.trialtimecourse.at3',squeeze(singtrialmean(:, 1:end-2, 3)),[],[], 1,[],[],[],[],1);
SaveAvgFile('GM7.trialtimecourse.at4',squeeze(singtrialmean(:, 1:end-2, 4)),[],[], 1,[],[],[],[],1);
SaveAvgFile('GM7.trialtimecourse.at5',squeeze(singtrialmean(:, 1:end-2, 5)),[],[], 1,[],[],[],[],1);

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