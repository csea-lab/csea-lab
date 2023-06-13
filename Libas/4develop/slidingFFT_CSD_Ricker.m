% THIS CODE CALCULATES THE FFT FROM THE SLIDING WINDOWS OBTAINED FROME EACH INDIVIDUAL TRIAL
% THIS CODE ALSO CALCULATES THE CURRENT SOURCE DENSITY -CSD- (THE CURRENT AT THE SURFACE OF THE BRAIN)

clear 

cd '/Users/andreaskeil/Desktop/Gaborgen_Laura/StartingPoint/Gaborgen24/CSDfiles'

% THIS CODE MAKES THE CSD TRANSFORMATION (COMMENT AFTER RUNNING FOR THE FIRST TIME)

% filemat = getfilesindir(pwd, '*.mat')
% 
% %filemat = filemat(1:2:end,:);
% 
% for index = 1: size(filemat,1) 
%     
%     a = load(deblank(filemat(index,:))); 
%     
%     CSDarray = Array2Csd(a.outmat, .1, 'HC1-129.ecfg');
%     
%     eval(['save ' deblank(filemat(index,:)) '.csd.mat CSDarray -mat'])
%     
% end

%delete('*slidwin*')

filemat = getfilesindir(pwd, '*app*.csd.mat');

 time = 901:1501; %start after onset ERP
%  time = 501:1501; %start window right after onset

for index = 1:size(filemat,1) % here we obtain the FFT of the sliding windows using the function freqtag_slidewin
    
    name = deblank(filemat(index,:));
    
    load(name);
    
    data = CSDarray; 
    
    [trialamp15,winmat3d15,phasestabmat,trialSNR15] = freqtag_slidewin(data, 0, 401:500, time, 15, 600, 500, name);
  
end


%% Here we obtain the average FFT across trials for the row data and for the SNR corrected data 

filemat = getfilesindir(pwd, '*win.mat');

    for index = 1:size(filemat,1)

        name = deblank(filemat(index,:));
    
        load(name);      
        
        temp = mean(outmat.fftamp,2); 
        
        SaveAvgFile([name(1:36) '.csdamp.at'], temp, [], [], 1);
        
        temp2 = mean(outmat.trialSNR,2); 
        
        SaveAvgFile([name(1:36) '.csdSNR.at'], temp2, [], [], 1);
        
    end
    
%% Here we obtain the grand mean across subjects, this file can be used for visualization in emegs
filemat = getfilesindir(pwd, '*amp.at');

mergemulticons(filemat, 12, 'GM31.fftamp') 

% for windowed FFT, SNR shoudl be noisier, but check if true

filemat = getfilesindir(pwd, '*SNR.at');

mergemulticons(filemat, 12, 'GM31.SNR') 

%% average FFT across trials for first and second half of each phase
filemat = getfilesindir(pwd, '*win.mat');

    for index = 1:size(filemat,1)

        name = deblank(filemat(index,:));
    
        load(name); 
        
        % amplitude
         
        temp1 = mean(outmat.fftamp(:,2:ceil(size(outmat.fftamp,2)./2)),2);
        
        emp2 = mean(outmat.fftamp(:,ceil(size(outmat.fftamp,2)./2)+1:end),2);
     
        if isnan(temp1(1)), temp1 = mean(outmat.fftamp,2); end
        if isnan(temp2(1)), temp2 = mean(outmat.fftamp,2); end
        
        SaveAvgFile([name(1:36) '.amp2part.csd.at'], [temp1 temp2], [], [], 1);
        
        % SNR
        
        temp1 = mean(outmat.trialSNR(:,2:ceil(size(outmat.trialSNR,2)./2)),2);
        
        temp2 = mean(outmat.trialSNR(:,ceil(size(outmat.trialSNR,2)./2)+1:end),2);
        
        if isnan(temp1(1)), temp1 = mean(outmat.trialSNR,2); end
        if isnan(temp2(1)), temp2 = mean(outmat.trialSNR,2); end
        
        SaveAvgFile([name(1:36) '.SNR2part.csd.at'], [temp1 temp2], [], [], 1);
        
    end

%% again grand mean across subjects for first and second half of each phase
filemat1 = getfilesindir(pwd, '*amp2part.csd.at');

mergemulticons(filemat1, 12, 'GM31.csd.amp2part') 

filemat2 = getfilesindir(pwd, '*SNR2part.csd.at');

mergemulticons(filemat2, 12, 'GM31.csd.SNR2part') 

%%
% This code separate each condition in different filemat objects (This code is only for early and late acquisition)
cd '/home/laura/Documents/Gaborgen24/raw eeg files/app/new_app_CSD'

clear 
filemat = getfilesindir(pwd, '*amp2part.csd.at');  % should be 372 files


conditions = [11:14 20 22 23 24 31:34];
for x = 1:12 % 12 conditions
    
    string = ['*.app' num2str(conditions(x)) '.amp2part.csd.at'];

    eval(['filemat' num2str(conditions(x)) ' = getfilesindir(pwd, string)']);
    
end


%% Ricker per individual / early acquisition 1 & late acquisition 2

options.MaxIter = 100000; 

for subject = 1:size(filemat11,1) % 31 subjects
    
    CSp = ReadAvgFile(filemat20(subject,:));
    GS1 = ReadAvgFile(filemat22(subject,:));
    GS2 = ReadAvgFile(filemat23(subject,:));
    GS3 = ReadAvgFile(filemat24(subject,:));
     
    data4fit1 = [ CSp(:, 1) GS1(:, 1) GS2(:, 1) GS3(:, 1)]; % early trials
    data4fit1_scaling = rangecorrect(data4fit1);
    data4fit2 = [ CSp(:, 2) GS1(:, 2) GS2(:, 2) GS3(:, 2)]; % later trials
    data4fit2_scaling = rangecorrect(data4fit2);

    for elec = 1:129
       
        [beta_amp1_acq(elec, subject), ~, ~, ~, mseamp1_acq(elec,subject)] = nlinfit(1:4,data4fit1_scaling(elec,:)',@Ricker, .1, options);
        [beta_amp2_acq(elec, subject), ~, ~, ~, mseamp2_acq(elec, subject)] = nlinfit(1:4,data4fit2_scaling(elec,:)',@Ricker, .1, options);
        
    end

end


figure(22), plot(beta_amp1_acq), hold on, plot(beta_amp2_acq)

GMbeta_amp1_acq = mean(beta_amp1_acq,2);
SaveAvgFile('GM_gaborgen24_pilot_Rickerbeta_scl_acq1.at', GMbeta_amp1_acq)
GMbeta_amp2_acq= mean(beta_amp2_acq,2);
SaveAvgFile('GM_gaborgen24_pilot_Rickerbeta_scl_acq2.at', GMbeta_amp2_acq)

GMmseamp1_acq = mean(mseamp1_acq,2);
SaveAvgFile('GM_gaborgen24_pilot_Ricketmse_scl_acq1.at', GMmseamp1_acq)
GMmseamp2_acq = mean(mseamp2_acq,2);
SaveAvgFile('GM_gaborgen24_pilot_Ricketmse_scl_acq2.at', mseamp2_acq)

%%
% This code separate each condition in different filemat objects (for all phases, whithout separating early and late trials)
cd '/home/laura/Documents/Gaborgen24/raw eeg files/app/new_app_CSD'

clear 
filemat = getfilesindir(pwd, '*.csdamp.at');  % should be 372 files


conditions = [11:14 20 22 23 24 31:34];
for x = 1:12 % 12 conditions
    
    string = ['*.app' num2str(conditions(x)) '.csdamp.at'];

    eval(['filemat' num2str(conditions(x)) ' = getfilesindir(pwd, string)']);
    
end

%% Ricker per individual / habituation 

options.MaxIter = 100000; 


for subject = 1:size(filemat31,1) % 31 subjects
    
    CSp = ReadAvgFile(filemat11(subject,:));
    GS1 = ReadAvgFile(filemat12(subject,:));
    GS2 = ReadAvgFile(filemat13(subject,:));
    GS3 = ReadAvgFile(filemat14(subject,:));
     
    data4fit = [ CSp(:, 1) GS1(:, 1) GS2(:, 1) GS3(:, 1)];

    % Here we standardize the data
    data4fit_scaling = rangecorrect(data4fit);
  
    for elec = 1:129
        
        [beta_amp_hab(elec, subject), ~, ~, ~, mse_amp_hab(elec,subject)] = nlinfit(1:4,data4fit_scaling(elec,:)',@Ricker, .1, options);

    end

end

GMbeta_amp_hab = mean(beta_amp_hab,2);
SaveAvgFile('GM_gaborgen24_pilot_Rickerbeta_scl_hab.at', GMbeta_amp_hab)

GMmseamp_hab = mean(mse_amp_hab,2);
SaveAvgFile('GM_gaborgen24_pilot_Ricketmse_scl_hab.at', GMmseamp_hab)

%% Ricker per individual / acquisition 

options.MaxIter = 100000; 


for subject = 1:size(filemat31,1) % 31 subjects
    
    CSp = ReadAvgFile(filemat20(subject,:));
    GS1 = ReadAvgFile(filemat22(subject,:));
    GS2 = ReadAvgFile(filemat23(subject,:));
    GS3 = ReadAvgFile(filemat24(subject,:));
     
    data4fit = [ CSp(:, 1) GS1(:, 1) GS2(:, 1) GS3(:, 1)];

    % Here we standardize the data
    data4fit_scaling = rangecorrect(data4fit);
  
    for elec = 1:129
        
        [beta_amp_acq(elec, subject), ~, ~, ~, mse_amp_acq(elec,subject)] = nlinfit(1:4,data4fit_scaling(elec,:)',@Ricker, .1, options);

    end

end

GMbeta_amp_acq = mean(beta_amp_acq,2);
SaveAvgFile('GM_gaborgen24_pilot_Rickerbeta_scl_acq.at', GMbeta_amp_acq)

GMmseamp_acq = mean(mse_amp_acq,2);
SaveAvgFile('GM_gaborgen24_pilot_Ricketmse_scl_acq.at', GMmseamp_acq)

%% Ricker per individual / extinction 

options.MaxIter = 100000; 


for subject = 1:size(filemat31,1) % 31 subjects
    
    CSp = ReadAvgFile(filemat31(subject,:));
    GS1 = ReadAvgFile(filemat32(subject,:));
    GS2 = ReadAvgFile(filemat33(subject,:));
    GS3 = ReadAvgFile(filemat34(subject,:));
     
    data4fit = [ CSp(:, 1) GS1(:, 1) GS2(:, 1) GS3(:, 1)];

    % Here we standardize the data
    data4fit_scaling = rangecorrect(data4fit);
  
    for elec = 1:129
        
        [beta_amp_ext(elec, subject), ~, ~, ~, mse_amp_ext(elec,subject)] = nlinfit(1:4,data4fit_scaling(elec,:)',@Ricker, .1, options);

    end

end

GMbeta_amp_ext = mean(beta_amp_ext,2);
SaveAvgFile('GM_gaborgen24_pilot_Rickerbeta_scl_ext.at', GMbeta_amp_ext)

GMmseamp_ext = mean(mse_amp_ext,2);
SaveAvgFile('GM_gaborgen24_pilot_Ricketmse_scl_ext.at', GMmseamp_ext)

%% Ricker versus flat distribution in acquisition and extinction 

clear
filemat = getfilesindir(pwd, '*csdamp.at');
repmat = squeeze(makerepmat(filemat, 31, 12, []));
testmat = squeeze(repmat(75,:,:)); % Only for the sensor 75

options.MaxIter = 100000; 

% Acquisition
for subject = 1:31    
   data_acq =  testmat(subject, 5:8); 
   [beta_acq(subject), ~, ~, ~, mse_acq(subject)] = nlinfit(0.25:0.25:1,rangecorrect(data_acq'),@Ricker, .1, options);     
   fit_acq(subject,:) = Ricker(0.25:0.25:1, beta_acq(subject)); 
   residualsRicker(subject) = mean((fit_acq(subject,:)-rangecorrect(data_acq)).^2);
   residualsNull(subject) = mean((rangecorrect(data_acq)).^2);
end

% Extinction
for subject = 1:31    
   data_ext =  testmat(subject, 9:12); 
   [beta_ext(subject), ~, ~, ~, mse_ext(subject)] = nlinfit(0.25:0.25:1,rangecorrect(data_ext'),@Ricker, .1, options);     
   fit_ext(subject,:) = Ricker(0.25:0.25:1, beta_ext(subject)); 
   residualsRicker_ext(subject) = mean((fit_ext(subject,:)-rangecorrect(data_ext)).^2);
   residualsNull_ext(subject) = mean((rangecorrect(data_ext)).^2);
end

%% Gaussian fit versus flat distribution in acquisition and extinction 

filemat = getfilesindir(pwd, '*csdamp.at');
repmat = squeeze(makerepmat(filemat, 31, 12, []));
testmat = squeeze(repmat(75,:,:)); % Only for the sensor 75

options.MaxIter = 100000; 

% Acquisition
for subject = 1:31    
   data_acq =  testmat(subject, 5:8); 
   [beta_acqG(subject), ~, ~, ~, mse_acqG(subject)] = nlinfit(0.25:0.25:1,rangecorrect(data_acq),@Gaussian, .1, options);     
   fit_acqG(subject,:) = Gaussian(beta_acqG(subject),0.25:0.25:1); 
   residualsGaussian(subject) = mean((fit_acqG(subject,:)-rangecorrect(data_acq)).^2);
   residualsNullG(subject) = mean((rangecorrect(data_acq)).^2);
end

% Extinction
for subject = 1:31    
   data_ext =  testmat(subject, 9:12); 
   [beta_extG(subject), ~, ~, ~, mse_extG(subject)] = nlinfit(0.25:0.25:1,rangecorrect(data_ext),@Gaussian, .1, options);     
   fit_extG(subject,:) = Gaussian(beta_extG(subject),0.25:0.25:1); 
   residualsGaussian_ext(subject) = mean((fit_extG(subject,:)-rangecorrect(data_ext)).^2);
   residualsNull_extG(subject) = mean((rangecorrect(data_ext)).^2);
end

%% Figures per subject

for subject = 1:31
    figure(100); plot(fit_acq(subject,:)); hold on; plot(fit_acqG(subject,:),"g");
    plot(rangecorrect(testmat(subject,5:8)), "r");
    title(['Acquisition: blue=Ricker/green=Gaussian/red=data. S=' num2str(subject)]);
    pause
    hold off
end

%%
%% ssVEP data early and late Acquisition / all sensors (range corrected)
for subject = 1:size(filemat31,1) % 31 subjects
    
    CSp = ReadAvgFile(filemat20(subject,:));
    GS1 = ReadAvgFile(filemat22(subject,:));
    GS2 = ReadAvgFile(filemat23(subject,:));
    GS3 = ReadAvgFile(filemat24(subject,:));
     
    data_acq1 = [ CSp(:, 1) GS1(:, 1) GS2(:, 1) GS3(:, 1)];
    data_acq1_scaling (:,:,subject) = rangecorrect(data_acq1);
    data_acq2 = [ CSp(:, 2) GS1(:, 2) GS2(:, 2) GS3(:, 2)];
    data_acq2_scaling (:,:,subject) = rangecorrect(data_acq2);

end

GM31_scl_acq1 = squeeze(mean(data_acq1_scaling,3));
SaveAvgFile('GM_gaborgen24_pilot_sclDATA_acq1.at', GM31_scl_acq1)
GM31_scl_acq2 = squeeze(mean(data_acq2_scaling,3));
SaveAvgFile('GM_gaborgen24_pilot_sclDATA_acq2.at', GM31_scl_acq2)

%% ssVEP data early and late Extinction / all sensors (range corrected)
for subject = 1:size(filemat31,1) % 31 subjects
    
    CSp = ReadAvgFile(filemat31(subject,:));
    GS1 = ReadAvgFile(filemat32(subject,:));
    GS2 = ReadAvgFile(filemat33(subject,:));
    GS3 = ReadAvgFile(filemat34(subject,:));
     
    data_ext1 = [ CSp(:, 1) GS1(:, 1) GS2(:, 1) GS3(:, 1)];
    data_ext1_scaling (:,:,subject) = rangecorrect(data_ext1);
    data_ext2 = [ CSp(:, 2) GS1(:, 2) GS2(:, 2) GS3(:, 2)];
    data_ext2_scaling (:,:,subject) = rangecorrect(data_ext2);

end

GM31_scl_ext1 = squeeze(mean(data_ext1_scaling,3));
SaveAvgFile('GM_gaborgen24_pilot_sclDATA_ext1.at', GM31_scl_ext1)
GM31_scl_ext2 = squeeze(mean(data_ext2_scaling,3));
SaveAvgFile('GM_gaborgen24_pilot_sclDATA_ext2.at', GM31_scl_ext2)