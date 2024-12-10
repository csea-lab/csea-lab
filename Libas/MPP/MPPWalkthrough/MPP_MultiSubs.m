%% IMPLEMENT MPP ALGORITHM ON ALPHA RHYTHMS AT OZ IN MULTIPLE SUBJECTS

%add data to path
fileDir = ''; %%INSERT PATH TO FOLDER HERE

%create character array of file names corresponding to CONDITION 12
fileMat = getfilesindir(fileDir, '*app12.mat'); %this can be done easily using 
                                            %getfilesindir.mat, a function
                                            %that is freely available in
                                            %the Libas folder of our
                                            %lab's Github:
                                            %https://github.com/csea-lab/csea-lab

%load filter into workspace
tmp1 = load('Filter_alpha_7_17Hz_Fs500Hz.mat');
alpha = tmp1.H3;

%set appropriate values for algorithm hyperparamters
M_alpha = 200;
K_alpha = 4;

%loop through subjects, applying the alpha filter and implementing
%the MPP algorithm to estimate and visualize oscillatory events for each
%subject
for i = 1:size(fileMat,1) %loop from 1 to number of files
    
    %load the ith file in the fileMat 
    fileName = fullfile(fileDir,fileMat(i,:));
    tmp = load(deblank(fileName));
    data = tmp.outmat;

    %apply alpha filter to data
    alphaSignal = filter(alpha,1,data);
    %save results
    save([fileName(1:end-4) '.alph.mat'], 'alphaSignal')

    %estimate MPPs at channel Oz in the Alpha frequency range
    alphaOz = squeeze(alphaSignal(75,:,:))'; %extract data for Oz
    [DalphaOz, MPPalphaOz, th_optAlphaOz] = PhEv_Learn_fast_2(alphaOz, M_alpha, K_alpha); %run MPP algorithm
    %save results
    save([fileName(1:end-4) '.alphMPPOz.mat'],'DalphaOz','MPPalphaOz','th_optAlphaOz')

    %extract timing information from MPP struct
    allTausAlpha = [];
    for t = 1:size(MPPalphaOz, 2)
        alphaTaus = MPPalphaOz(t).Trials.tau; %extract alpha taus for each trial
        allTausAlpha = [allTausAlpha alphaTaus]; %store alpha taus for all trials
    end
    
    %visualize event onsets across trials with Raster plot
    f_all = figure; f_all.Position = [680   400   1000   800]; 
    rasterplot(sort(allTausAlpha,'ascend'),1,2601,f_all,500), title(['Participant #' num2str(i) ': Alpha Events, All Trials'])
    pause(2) %displays Raster plot for each file for 2 seconds before saving onsets and looping through next file
    close all

    %Save oscillatory event time series information
    save([fileName(1:end-4) '.alph.tau.mat'],'allTausAlpha')

end