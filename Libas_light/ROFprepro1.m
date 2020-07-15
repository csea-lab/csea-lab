function [EEG, filepath] = ROFprepro1(filepath, trialvec)
%ROFprepro reads bdf file from project lens into matlab, cuts epochs and
%does ICA 

elp_path = '/Users/andreaskeil/As_Exps/KaraDawsonROF/karapasha21.elp'; 

datamat3d = []; 
EEG = pop_biosig(filepath, 'channels',[1:8 10:16 19:20 22:25] ,'importevent','off');
%EEG = pop_fileio(filepath, 'channels',[1:8 10:16 19:20 22:25]);

EEG = eeg_checkset( EEG );

EEG = pop_chanevent(EEG, 21,'edge','leading','edgelen',0);
EEG = eeg_checkset( EEG );

EEG.event, pause

EEG=pop_chanedit(EEG, 'load',{elp_path 'filetype' 'autodetect'},'changefield',{21 'datachan' 0},'setref',{'21' 'Pz'});
EEG = eeg_checkset( EEG );

EEG = pop_selectevent( EEG, 'event',trialvec,'deleteevents','on'); EEG = eeg_checkset( EEG );

trigname = EEG.event.type

datatemp = EEG.data';
[afil, bfil] = butter(5, .2); 
datatemp2 = filtfilt(afil, bfil, double(datatemp)); 
EEG.data = single(datatemp2'); 
EEG = eeg_checkset( EEG );

[afil, bfil] = butter(3, .01, 'high'); 
datatemp2 = filtfilt(afil, bfil, double(datatemp)); 
EEG.data = single(datatemp2'); 
EEG = eeg_checkset( EEG );

%EEG = pop_epoch( EEG, {  trigname }, [-1  5], 'newname', 'EDF file epochs', 'epochinfo', 'yes'); for 2to 12

EEG = pop_epoch( EEG, {  trigname }, [-1  5], 'newname', 'EDF file epochs', 'epochinfo', 'yes');

EEG = eeg_checkset( EEG );
EEG = pop_rmbase( EEG, [-1000     0]);
EEG = eeg_checkset( EEG );

EEG = pop_runica(EEG, 'extended',1,'interupt','on');

pop_topoplot(EEG,0, [1:20] ,'component topographies',[4 5] ,0,'electrodes','on');

