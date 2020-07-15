
function [EEG] = anna_vespa_prepro(EEGfilepath)

EEG = pop_fileio(EEGfilepath);

EEG = eeg_checkset( EEG );

% filter the data
temp = EEG.data'; 

[fila,filb] = butter(4, 0.12); 

temp2 = filtfilt(fila, filb, double(temp)); 

[filaH,filbH] = butter(4, 0.0004, 'high');

temp3 =  filtfilt(filaH, filbH, temp2)'; 

EEG.data = single(temp3);

EEG = eeg_checkset( EEG );

EEG=pop_chanedit(EEG, 'load',{'GSN-HydroCel-129.sfp' 'filetype' 'autodetect'},'changefield',{132 'datachan' 0},'setref',{'132' 'Cz'});

EEG = eeg_checkset( EEG );

EEG= pop_epoch( EEG, {  'DIN4'  }, [-1  180], 'newname', 'threeminutes', 'epochinfo', 'yes');

EEG = eeg_checkset( EEG);

EEG = pop_rmbase( EEG, [1000     1500]);


% run the ICA and save  output
EEG = pop_runica(EEG,  'icatype', 'sobi');

EEG = eeg_checkset( EEG );
EEG = pop_saveset( EEG, 'filename',[EEGfilepath '.EEG1.set'],'filepath',pwd);
EEG = eeg_checkset( EEG );



warning('off');
pop_topoplot(EEG,0, [1:64] ,'component topographies',[8 8] ,0,'electrodes','off');
warning('on');



EEG = pop_subcomp( EEG, componentsremove, 0);


outmat3d_aftertrialAR = avg_ref_add3d(outmat3d_aftertrial); 

EEG.data = outmat3d_aftertrialAR; 




