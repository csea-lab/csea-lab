function [EEG_3D] =  CSEA_eeglab_prepro (datapath)

     %read data into eeglab
     EEG = pop_fileio(datapath, 'dataformat','auto');
     EEG.setname='temp';
     EEG = eeg_checkset( EEG );
     
     % bandpass filter
     EEG = pop_eegfiltnew(EEG, 'locutoff',3,'hicutoff',34,'plotfreqz',1);
     EEG = eeg_checkset( EEG );

     % add electrode locations
     EEG=pop_chanedit(EEG, 'lookup','/Users/andreaskeil/Documents/GitHub/csea-lab/Libas/4data/HCGSNSensorPostionFiles/GSN-HydroCel-256.sfp');
     EEG = eeg_checkset( EEG );

     
    
     % happy
     EEG_3D = pop_epoch( EEG, {  'DIN3'  }, [-0.6 5.6], 'newname', 'epochs', 'epochinfo', 'yes');
     EEG_3D = pop_rmbase( EEG_3D, [-600 0] ,[]);
     EEG_3D = eeg_checkset( EEG_3D );
     [EEG_3D, rejectepochs] = pop_autorej(EEG_3D, 'nogui','on','threshold',500,'electrodes',[1:256] ,'eegplot','on');
     EEG_3D = eeg_checkset( EEG_3D );
     EEG_3D = pop_rejepoch( EEG_3D, rejectepochs,0);
     
     save([datapath(1:end-4) '.cleaneeg.mat'],  'EEG_3D', '-mat')

