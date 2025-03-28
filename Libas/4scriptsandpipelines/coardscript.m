% coardscript
% explores correlations in COARD data for combined HC, OCD, and HD
clc
%% get the file lists
cd ('/Users/andreaskeil/Desktop/COARD/COARD_NEW HC allcond wavelet files')
filemat1 = getfilesindir(pwd, '*a.pow3.mat')
size(filemat1) % should be 35 people
 
cd ('/Users/andreaskeil/Desktop/COARD/COARD_NEW OCD allcond wavelet files')
filemat2 = getfilesindir(pwd, '*a.pow3.mat')
size(filemat2) % should be 26 people

cd ('/Users/andreaskeil/Desktop/COARD/COARD_NEW HD allcond wavelet files')
filemat3 = getfilesindir(pwd, '*a.pow3.mat')
size(filemat3) % should be 33 people

pause

%%
% make submatrices and then combine

bsl = 100:600; 

clc
disp(' ')
disp('Healthy Controls')

manymat1 = []; 
cd ('/Users/andreaskeil/Desktop/COARD/COARD_NEW HC allcond wavelet files')
for x = 1:size(filemat1,1)   
    a = load(deblank(filemat1(x,:))); 
    mat = eval(['a.' char(fieldnames(a))]);
    mat = bslcorrWAMatFast(mat, bsl, 'subtract');  % bsl
    manymat1(: , :, :, x) = mat;   
    fprintf([num2str(x) ' '])
end

disp(' ')
disp('OCD')

manymat2 = []; 
cd ('/Users/andreaskeil/Desktop/COARD/COARD_NEW OCD allcond wavelet files')
for x = 1:size(filemat2,1)   
    a = load(deblank(filemat2(x,:))); 
    mat = eval(['a.' char(fieldnames(a))]);
    mat = bslcorrWAMatFast(mat, bsl, 'subtract');  % bsl
    manymat2(: , :, :, x) = mat;   
    fprintf([num2str(x) ' '])
end

disp(' ')
disp('Hoarding')

manymat3 = []; 
cd ('/Users/andreaskeil/Desktop/COARD/COARD_NEW HD allcond wavelet files')
for x = 1:size(filemat3,1)   
    a = load(deblank(filemat3(x,:))); 
    mat = eval(['a.' char(fieldnames(a))]);
    mat = bslcorrWAMatFast(mat, bsl, 'subtract');  % bsl
    manymat3(: , :, :, x) = mat;   
    fprintf([num2str(x) ' '])
end

allmat4stats = cat(4, manymat1, manymat2, manymat3); 
%% compute correlations 
peoplevec = 36:94;
disp(' ')
disp('correlations with sensor: ')
corrmat = []; 
for elec = 1:size(allmat4stats,1)
    for time = 1:1433
        for freq = 1:62
            temp = corrcoef(squeeze(allmat4stats(elec, time, freq, peoplevec)), BAI(peoplevec));
            
            corrmat(elec, time, freq) = temp(2,1); 
            
        end
    end
    if elec/10 == round(elec/10)
    fprintf([num2str(elec) ' '])
    end
end

%% plots
clc
figure
taxis = -600:1000/1024:800-1000/1024;
faxis = 3*(1000/1400):1000/1400:64*(1000/1400);

for elec = 1:size(corrmat,1)
    contourf(taxis, faxis, squeeze(corrmat(elec, :, :))'); caxis([-.4 .4]), colorbar, title(num2str(elec)), pause
end

%% plot ERP correlation (lowest freq as line plot 
clc 
figure
taxis = -600:1000/1024:800-1000/1024;
freqselect  = 45

for elec = 1:size(corrmat,1)
    subplot(2,1,1), plot(taxis, squeeze(corrmat(elec, :, freqselect))'); title(num2str(elec))
    subplot(2,1,2), plot(BAI(peoplevec), squeeze(allmat4stats(elec, 800, freqselect, peoplevec)), 'ro'), lsline
    pause
end

 plot(BAI(peoplevec), squeeze(allmat4stats(42, 800, freqselect, peoplevec)), 'ko', 'MarkerFaceColor','r')

            