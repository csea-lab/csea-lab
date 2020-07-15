% Scads2fieldtrip
function [EEG] = scads2eeglab(filemat, bslrange); 

%
load locsEEGLAB129HCL.mat

for index = 1:size(filemat)
    
    atfilepath = deblank(filemat(index,:)); 

[AvgMat,File,Path,FilePath,NTrialAvgVec,StdChanTimeMat,...
	SampRate,AvgRef,Version,MedMedRawVec,MedMedAvgVec,EegMegStatus,...
    NChanExtra,TrigPoint,HybridFactor,HybridDataCell,DataTypeVal]=ReadAvgFile(atfilepath);

AvgMat = bslcorr(AvgMat, bslrange); 

[AvgMat, interpsensvec] = scadsAK_3dchan(AvgMat, locsEEGLAB129HCL);


EEG = pop_importdata('dataformat','array','nbchan',0,'data',AvgMat,'setname','test','srate',500,'pnts',3001,'xmin',-3);

EEG=pop_chanedit(EEG, 'load',{'/Users/andreaskeil/matlab_as/emegs2.8/emegs2dUtil/SensorCfg/HC1-129.sfp' 'filetype' 'sfp'})

EEG = eeg_checkset( EEG );


EEG = pop_saveset( EEG, 'filename',[atfilepath '.set'],'filepath', pwd);
EEG = eeg_checkset( EEG );


end
 
 