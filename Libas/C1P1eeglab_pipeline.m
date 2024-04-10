
function [EEG] = C1P1eeglab_pipeline(EEGfilepath)

EEG = pop_readegi(EEGfilepath, [],[],'auto');

EEG = eeg_checkset( EEG );

codes = load("event_codes_c1p1_test.txt");

% filter the data
temp = EEG.data'; 

[fila,filb] = butter(4, 0.06); 

temp2 = filtfilt(fila, filb, double(temp)); 

[filaH,filbH] = butter(2, 0.002, 'high');

temp3 =  filtfilt(filaH, filbH, temp2)'; 

EEG.data = single(temp3);

EEG = eeg_checkset( EEG );
%EEG=pop_chanedit(EEG, 'load',{'/Users/cseauf/Documents/Arash/BOP_experiment/GSN-HydroCel-128.sfp' 'filetype' 'autodetect'});

EEG=pop_chanedit(EEG, 'load',{'GSN-HydroCel-257.sfp' 'filetype' 'autodetect'},'changefield',{260 'datachan' 0},'setref',{'260' 'Cz'});

% re-reference to average reference
EEG = pop_reref(EEG, [], 'keepref', 'on');

EEG = eeg_checkset( EEG );

% re-reference right mastoid & read back in channel locations 
%EEG = pop_eegchanoperator( EEG, '/Volumes/My Passport/c1p1/Right_Mastoid_Reference.txt');
EEG=pop_chanedit(EEG, 'load',{'GSN-HydroCel-257.sfp' 'filetype' 'autodetect'});


%% now the trigger issue, har har 
for index1 = 1:length(EEG.event)
temptrigs(index1) = EEG.event(index1).latency;
end

newtrigvec = []; 
indiceswithtrigs = find(diff(temptrigs) > 9); 
newtrigvec_temp = temptrigs(indiceswithtrigs+1);
newtrigvec = [temptrigs(1); newtrigvec_temp']; 

% replace trigger structures in EEG structure with actual triggers
EEG.event = []; 
EEG.urevent = []; 

% for index2 = 1:length(newtrigvec)
%     EEG.event(index2).type = num2str(codes(index2)); 
%     EEG.event(index2).latency = newtrigvec(index2);
%     EEG.event(index2).urevent = index2;
%     EEG.urevent(index2).type = 'DIN3';
%     EEG.urevent(index2).latency = newtrigvec(index2);
% end

event_codes = arrayfun(@num2str, codes, 'UniformOutput', false);

for index2 = 1:length(newtrigvec)
    EEG.event(index2).type = event_codes{index2};
    EEG.event(index2).latency = newtrigvec(index2);
    EEG.event(index2).urevent = index2;
    EEG.urevent(index2).type = event_codes{index2};
    EEG.urevent(index2).latency = newtrigvec(index2);
end



%resample to 250 Hz
EEG = pop_resample( EEG, 250);
EEG = eeg_checkset( EEG );

%run the ICA and save  output
EEG = pop_runica(EEG,  'icatype', 'sobi');
EEG = eeg_checkset( EEG );
% EEG = pop_saveset( EEG, 'filename', '515.EEG.set','filepath',pwd);
% EEG = eeg_checkset( EEG );


% EEG = pop_epoch( EEG, {  'DIN3'  }, [-.2  .3], 'newname', 'test epochs', 'epochinfo', 'yes');
% EEG = eeg_checkset( EEG );
% EEG = pop_rmbase( EEG, [-100     0]);
% 
% % take care of bad channels
% [outmat3d, interpsensvec] = scadsAK_3dchan(EEG.data, EEG.chanlocs);
% EEG.data = single(outmat3d); 

% % 
%  warning('off');
%  pop_topoplot(EEG,0, [1:64] ,'component topographies',[8 8] ,0,'electrodes','off');
%  warning('on');


