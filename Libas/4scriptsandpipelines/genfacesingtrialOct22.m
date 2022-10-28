%single trial analyses for the genface study
%%
clear
% go to the right folder
cd '/Users/andreaskeil/Desktop/Genface10_22/matfiles'
%%
% do the single trial analysis on the correct time frame
delete *slidwin.mat
pause(2)
taxis = -800:2:2200; 
filemat = getfilesindir(pwd, '*.mat'); % should be 462 files for 33 people

for index1 = 1:size(filemat,1)
    
    a = load(filemat(index1,:)); 
    data = a.outmat; 
    [trialamp,winmat3d,phasestabmat,trialSNR] = freqtag_slidewin(data, 0, 200:400, 400:1400, 15, 600, 500, filemat(index1,:));
    
end

% takes about 15 minutes on andreas' mac

%% do the interpolation into trial bins separately, then
%  save the bin files in at format

clear 
filemat = getfilesindir(pwd, '*win.mat');  % should be 462 files

delete *SNR.at
delete *amp.at

pause(2)

    
   for index1 = 1:size(filemat,1)
        
         a = load(filemat(index1,:)); 
            data1 = a.outmat.fftamp;         
            data2 = a.outmat.trialSNR;
            
            dataout1 = resample(data1', 10, size(data1,2))';
            SaveAvgFile([filemat(index1,:) '.amp.at'],dataout1(:, 2:end-2)); 
        
            dataout2 = resample(data2', 10, size(data2,2))';
            SaveAvgFile([filemat(index1,:) '.SNR.at'],dataout2(:, 2:end-2));         
   
   end
%%
% read and resample the fftamps and SNRs for each file pair, make a new at file
% with trials for each person and condition, combining the two sections
% (early and late) 

% for amp
clear 
filemat = getfilesindir(pwd, '*amp.at');  % should be 462 files

for face = 1:7   
    counter = 1;  
    for index1 = face:7:size(filemat,1)
         
        if rem(counter,2) % odd numbers            
            data1 = ReadAvgFile(filemat(index1,:));           
        end
        
        if ~rem(counter,2) % even numbers            
           data2 = ReadAvgFile(filemat(index1,:));       
            
            temp = [data1 data2];
            databoth = movmean(temp',3, 'Endpoints','discard')';
            
            SaveAvgFile([filemat(index1,:) '.14.at'],databoth);             
        end   
     counter = counter + 1;     
    end
end
%%
% for SNR
clear 
filemat = getfilesindir(pwd, '*SNR.at');  % should be 462 files

for face = 1:7   
    counter = 1;  
    for index1 = face:7:size(filemat,1)
         
        if rem(counter,2) % odd numbers            
            data1 = ReadAvgFile(filemat(index1,:));           
        end
        
        if ~rem(counter,2) % even numbers            
           data2 = ReadAvgFile(filemat(index1,:));       
            
           temp = [data1 data2];
           databoth = movmean(temp',3, 'Endpoints','discard')';
            
            SaveAvgFile([filemat(index1,:) '.14.at'],databoth);             
        end   
     counter = counter + 1;     
    end
end

%%
% now read the avgfiles and make grand means as appropriate
% first amplitude
clear
filematamp = getfilesindir(pwd, '*.amp.at.14.at');  % should be 462 files
filematsnr = getfilesindir(pwd, '*.SNR.at.14.at');  % should be 462 files

mergemulticons(filematamp, 7, 'GM33.tamp')
mergemulticons(filematsnr, 7, 'GM33.SNR')

%%    
clear
filematamp = getfilesindir(pwd, '*.amp.at');  % should be 462 files
filematsnr = getfilesindir(pwd, '*.SNR.at');  % should be 462 files

mergemulticons(filematamp, 14, 'GM33.tamp')
mergemulticons(filematsnr, 14, 'GM33.SNR')   

delete *.log

%% make a matrix for repmat 

filematamp = getfilesindir(pwd, '*.amp.at.14.at');  % should be 462 files
[repmatamp] = makerepmat(filematamp, 33, 7);
%%
generalization = [-1.0 -0.5 0.5 2.0 0.5 -0.5 -1]; 
latinihib = [0.5 -1.0 -2.0 5.0 -2.0 -1.0 0.5];

for time = 1:12
    [FcontmatGen(:, time),rcontmatGen(:, time),MScont,MScs, dfcs]=contrast_rep(squeeze(repmatamp(:, time, :, :)) ,generalization);   
end

 SaveAvgFile('FcontmatGen.at', FcontmatGen); 

for time = 1:12
    [FcontmatLat(:, time),rcontmatLat(:, time),MScont,MScs, dfcs]=contrast_rep(squeeze(repmatamp(:, time, :, :)) ,latinihib);   
end

 SaveAvgFile('FcontmatLat.at', FcontmatLat); 


