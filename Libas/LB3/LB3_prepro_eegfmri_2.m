function LB3_prepro_eegfmri_2(datafolder, filename, locations)
        %% set random number generator (just in case)
        rng(1);

         [~, basename, ~] = fileparts([datafolder '/' filename]); 
        
        %% initialize eeglab
        [ALLEEG, ~, ~, ~] = eeglab;
        %% load dataset
        disp('Step 1/7 - load EEG data');
        EEG = pop_loadset('filename', filename, 'filepath', datafolder); 
        [ALLEEG, EEG, ~] = eeg_store(ALLEEG, EEG, 0);
        %% Select components manually
        EEG = pop_iclabel(EEG, 'default');
        pop_viewprops(EEG, 0, 1:31, {'freqrange', [2 80], 'iclabel', 'on', 'plotmode', 'normal'});
        R1 = input('Highlight ICs to remove, update marks and then press enter');
        % Save Ics
        answer = inputdlg('Enter ICs', 'ICs removal', [1 31]);
        str = answer{1};
        excludeICs = str2num(str);

        %% ---  Close figures
        set(0,'ShowHiddenHandles','on');                   
        h = findall(0,'Type','figure');                    
        % Keep eeg window:
        keep = findall(0,'Type','figure','-regexp','Name','EEGLAB');
        h = setdiff(h, keep);                              
        set(h, 'CloseRequestFcn','');                      
        delete(h);                                        
        set(0,'ShowHiddenHandles','off');

        %% remove ICs
        disp('Step 2/7 - removing independent components from data');
        EEG = eeg_checkset(EEG);
        EEG = pop_subcomp(EEG, excludeICs, 0);
        
       %% find bad channels 
       [~, interpvec] = scadsAK_2dInterpChan(EEG.data(1:31,:), locations, 2.2);
        
        %% interpolate channels
        disp('Step 3/7 - interpolating channels');
        EEG = eeg_checkset(EEG);
        EEG = pop_interp(EEG, interpvec, 'spherical');

        %% apply average reference
        disp('Step 4/7 - apply average reference');
        EEG = eeg_checkset(EEG);
        EEG = pop_reref( EEG, [],'exclude',32);

        %% transform into CSD
        disp('Step 6/7 - CSD transformation');
        EEG = eeg_checkset(EEG);
        % we have to remove non-EEG channels for the ERPlab plugin to work
        EEG = pop_select(EEG, 'rmchannel',{'ECG'});
        % do the CSD transformation
       EEG = csdFromErplabAutomated(EEG, 4, 1e-5, 10);
        [~, EEG, ~] = pop_newset(ALLEEG, EEG, 1,'gui','off');

        %% save data in eeglab format
        disp('Step 7/7 - save preprocessed data');
        EEG = eeg_checkset(EEG);
        pop_saveset(EEG, 'filename',[basename '_prepro2.set'], ...
                         'filepath',datafolder);

        %% generate logfile
                logText = strcat(['logfile for' basename  'finish preprocessing'], '\n', ...
                   'date_time: ', string(datetime()), '\n', ...
                   'removed ICs: ', int2str(excludeICs), '\n', ...                   
                   'interpolated channels: ', sprintf('%s ',string(interpvec)));
        fID = fopen([datafolder '2_log_' basename '.txt'], 'w');
        fprintf(fID, logText);
        fclose(fID);
    end
