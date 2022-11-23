function [] = bingham_prepro(headerfilepath)

EEG = pop_fileio(headerfilepath); % headerfilepath in apostrophies. if correct, will change color :-) 
EEG.setname='t';
EEG = eeg_checkset( EEG );
EEG = pop_eegfiltnew(EEG, 'locutoff',3,'hicutoff',34,'plotfreqz',1);
EEG = eeg_checkset( EEG );
EEG = pop_epoch( EEG, { 'S239' }, [-0.6 5.6], 'newname', 't epochs', 'epochinfo', 'yes');
EEG = eeg_checkset( EEG );
EEG = pop_rmbase( EEG, [-600 0] ,[]);
EEG = eeg_checkset( EEG );
EEG = pop_autorej(EEG, 'nogui','on','threshold',500,'electrodes',[1:31] ,'eegplot','on');
EEG = eeg_checkset( EEG );
EEG = pop_rejepoch( EEG, 13,0);
