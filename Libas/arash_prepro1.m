
function [EEG1, EEG2] = arash_prepro1(EEGfilepath, datfilepath)

EEG = pop_fileio(EEGfilepath);
datfilepath  = (datfilepath);

EEG = eeg_checkset( EEG );

EEG = findtrigsEGI_eeglab(EEG);

[convec, EEG] = bop2con(datfilepath, EEG); 

% filter the data
temp = EEG.data'; 

[fila,filb] = butter(4, 0.12); 

temp2 = filtfilt(fila, filb, double(temp)); 

[filaH,filbH] = butter(4, 0.0004, 'high');

temp3 =  filtfilt(filaH, filbH, temp2)'; 

EEG.data = single(temp3);

EEG = eeg_checkset( EEG );
%EEG=pop_chanedit(EEG, 'load',{'/Users/cseauf/Documents/Arash/BOP_experiment/GSN-HydroCel-128.sfp' 'filetype' 'autodetect'});

EEG=pop_chanedit(EEG, 'load',{'GSN-HydroCel-129.sfp' 'filetype' 'autodetect'},'changefield',{132 'datachan' 0},'setref',{'132' 'Cz'});

EEG = eeg_checkset( EEG );
EEG1 = pop_epoch( EEG, {  '1'  }, [-4.5  2.5], 'newname', 'test epochs', 'epochinfo', 'yes');
EEG2 = pop_epoch( EEG, {  '2'  }, [-4.5  2.5], 'newname', 'test epochs', 'epochinfo', 'yes');

EEG1 = eeg_checkset( EEG1 );
EEG2 = eeg_checkset( EEG2 );
EEG1 = pop_rmbase( EEG1, [1000     1500]);
EEG2 = pop_rmbase( EEG2, [1000     1500]);

% take care of bad channels
[outmat3d, interpsensvec] = scadsAK_3dchan(EEG1.data, EEG1.chanlocs);

EEG1.data = single(outmat3d); 

outmat3d_afterchan = EEG1.data;

[outmat3d, interpsensvec] = scadsAK_3dchan(EEG2.data, EEG2.chanlocs);

EEG2.data = single(outmat3d); 


% run the ICA and save  output
EEG1 = pop_runica(EEG1,  'icatype', 'sobi');
EEG1 = eeg_checkset( EEG1 );
EEG1 = pop_saveset( EEG1, 'filename',[EEGfilepath '.EEG1.set'],'filepath',pwd);
EEG1 = eeg_checkset( EEG1 );

EEG2 = pop_runica(EEG2,  'icatype', 'sobi');
EEG2 = eeg_checkset( EEG2 );
EEG2 = pop_saveset( EEG2, 'filename',[EEGfilepath '.EEG2.set'],'filepath',pwd);
EEG2 = eeg_checkset( EEG2 );

warning('off', 'warning off');
pop_topoplot(EEG1,0, [1:64] ,'component topographies',[8 8] ,0,'electrodes','off');
warning('on', 'warning on');


