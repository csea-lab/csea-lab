% bingham loop pipeline for processing EEG files
clear
% 1 make the filemats for prepro
filemat_eeg = getfilesindir(pwd, '*Facebor*.vhdr');
filemat_dat = getfilesindir(pwd, '*Facebor*.dat');

npeople = 10;

% below is just for testing the matrices
disp([filemat_dat(1:npeople,:) filemat_eeg(1:npeople,:)])

%% if correct, overwrite the matrices
filemat_eeg = filemat_eeg(1:npeople,:); 
filemat_dat = filemat_dat(1:npeople,:);
%%
% start a loop
for fileindex = 1:size(filemat_dat,1)
bingham_prepro(deblank(filemat_eeg(fileindex,:)), deblank(filemat_dat(fileindex,:)));
end

%% if the prepro makes sense then you may run this
clear
filemat_gaborERPs = getfilesindir(pwd, '*zGabor*eeg.mat');
filemat_faceERPs = getfilesindir(pwd, '*zFace*eeg.mat');

% a loop to do the gabor spectra
for fileindex = 1:size(filemat_gaborERPs,1)
    datapath = deblank(filemat_gaborERPs(fileindex,:)); 
    [ERP_happy, ERP_angry, ERP_sad, stats_amp, stats_SNR] =  bingham_postpro(datapath, 2);   
end
for fileindex = 1:size(filemat_faceERPs,1)
    datapath = deblank(filemat_faceERPs(fileindex,:)); 
    [ERP_happy, ERP_angry, ERP_sad, stats_amp, stats_SNR] =  bingham_postpro(datapath, 1);   
end