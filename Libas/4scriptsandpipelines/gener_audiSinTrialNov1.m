%single trial analyses for the gener_audi study
%%
clear
% go to the right folder
cd '/Users/andreaskeil/Desktop/Gener_audi_ASSR'
%%
% do the single trial analysis on the correct time frame
delete *slidwin.mat
pause(2)
taxis = -600:2:3000; 
filemat = getfilesindir(pwd, '*.mat'); % should be 59 files for 59 people

for index1 = 1:size(filemat,1)
        
    a = load(filemat(index1,:)); 
    
    names = fieldnames(a.Apps); 
    
    for condition = 1:6
        data = eval(['a.Apps.' names{condition}]);
        datacsd = Array2Csd(data, 2, 'HC1-129.ecfg'); % optional CSD
        %[trialamp,winmat3d,phasestabmat,trialSNR] = freqtag_slidewin(data, 0, 200:300, 301:1800, 41.2, 600, 500, [filemat(index1,:) names{condition}]);
        %[trialamp,winmat3d,phasestabmat,trialSNR] = flex_slidewin(data, 0, 200:300, 301:1801, 41.2, 600, 500, [filemat(index1,1:14) names{condition}]);
         [trialamp,winmat3d,phasestabmat,trialSNR] = flex_slidewin(datacsd, 0, 200:300, 301:1801, 41.2, 600, 500, [filemat(index1,1:14) names{condition}]);
    end
end

% takes about 60 minutes on andreas' mac

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
            SaveAvgFile([filemat(index1,:) '.amp.at'],dataout1(:, 2:end-1)); 
        
            dataout2 = resample(data2', 10, size(data2,2))';
            SaveAvgFile([filemat(index1,:) '.SNR.at'],dataout2(:, 2:end-1));         
   
   end
%%
% read and resample the fftamps and SNRs for each file pair, make a new at file
% with trials for each person and condition, combining the two sections
% (early and late) 

% for amp
clear 
filemat = getfilesindir(pwd, '*amp.at');  % should be 354 files

for tone = 1:3   
    counter = 1;  
    for index1 = tone:3:size(filemat,1)
         
        if rem(counter,2) % odd numbers            
            data1 = ReadAvgFile(filemat(index1,:));           
        end
        
        if ~rem(counter,2) % even numbers            
           data2 = ReadAvgFile(filemat(index1,:));       
            
            temp = [data1 data2];
            databoth = movmean(temp',3, 'Endpoints','discard')';
            
            SaveAvgFile([filemat(index1,:) '.ses.at'],databoth);             
        end   
     counter = counter + 1;     
    end
end
%%
% for SNR
clear 
filemat = getfilesindir(pwd, '*SNR.at');  % should be 462 files

for tone = 1:3   
    counter = 1;  
    for index1 = tone:3:size(filemat,1)
         
        if rem(counter,2) % odd numbers            
            data1 = ReadAvgFile(filemat(index1,:));           
        end
        
        if ~rem(counter,2) % even numbers            
           data2 = ReadAvgFile(filemat(index1,:));       
            
           temp = [data1 data2];
           databoth = movmean(temp',3, 'Endpoints','discard')';
            
            SaveAvgFile([filemat(index1,:) '.ses.at'],databoth);             
        end   
     counter = counter + 1;     
    end
end

%%
% now read the avgfiles and make grand means as appropriate
% first amplitude
clear
filematamp = getfilesindir(pwd, '*.amp.at.ses.at');  % should be 177 files
mergemulticons(filematamp, 3, 'GM59.tamp')


delete *.log

%% make a matrix for repmat: amplitude

filematamp = getfilesindir(pwd, '*.amp.at.ses.at');  % should be 177 files
[repmatamp] = makerepmat(filematamp, 59, 3);
%%
generalization = [2 .5 -2.5]; 
latinihib = [2 -2.5 .5];

for time = 1:size(repmatamp,2)
    [FcontmatGen(:, time),rcontmatGen(:, time),MScont,MScs, dfcs]=contrast_rep(squeeze(repmatamp(:, time, :, :)) ,generalization);   
end

 SaveAvgFile('FcontmatGen.at', FcontmatGen); 

for time = 1:size(repmatamp,2)
    [FcontmatLat(:, time),rcontmatLat(:, time),MScont,MScs, dfcs]=contrast_rep(squeeze(repmatamp(:, time, :, :)) ,latinihib);   
end

 SaveAvgFile('FcontmatLat.at', FcontmatLat); 


