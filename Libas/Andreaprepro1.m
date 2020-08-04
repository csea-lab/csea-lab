function [ EEG ] = Andreaprepro1( filepath )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
EEG = pop_biosig(filepath, 'channels',[1:28] ,'importevent','off');
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'gui','off');
EEG = eeg_checkset( EEG );
EEG = pop_chanevent(EEG, 28,'edge','leading','edgelen',0);
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = pop_eegfiltnew(EEG, 1, 40, 826, 0, [], 1);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off');
EEG=pop_chanedit(EEG, 'load',{'C:\\Users\\Pasha\\Desktop\\LENS EEG Analysis\\lensconfig.elp' 'filetype' 'besa'});
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset( EEG );
EEG = pop_saveset(EEG, 'filepath', [filepath '.test'])




