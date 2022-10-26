%single trial analyses for the genface study
%%
clear
% go to the right folder
cd '/Users/andreaskeil/Desktop/Genface10_22/matfiles'

% do the single trial analysis on the correct time frame
taxis = -800:2:2200; 
c

for index1 = 1:size(filemat,1)
    
    a = load(filemat(index1,:)); 
    data = a.outmat; 
    [trialamp,winmat3d,phasestabmat,trialSNR] = freqtag_slidewin(data, 0, 200:400, 500:1450, 15, 600, 500, filemat(index1,:));
    
end

%%
% read and resample the fftamps for each file, make a resampled at file
% with trials for each
clear 
filemat = getfilesindir(pwd, '*win.mat');  % should be 462 files

for index1 = 1:size(filemat,1)
    
    a = load(filemat(index1,:)); 
    data = a.outmat.fftamp; 
    dataout = resample(data', 10, size(data,2))';
    SaveAvgFile([filemat(index1,:) '.at'],dataout); 
      
end

%% 
% now read the avgfiles and make grand means as appropriate
filemat = getfilesindir(pwd, '*win.mat.at');  % should be 462 files

mergemulticons(filemat, 14, 'GM33.trialamp');
