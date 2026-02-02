function LB3_prepro_eegfmri_1(datafolder, filename,newSamplingRate,filterCutOff)
        %% filterCutOff should be something like [1 40] 
        %% set random number generator (just in case)
        rng(1);
        %% identify basename of file
        [~, basename, ~] = fileparts([datafolder '/' filename]); 
        
        %% initialize eeg lab
        [ALLEEG, ~, ~, ~] = eeglab;
        
        %% load dataset
        disp('Step 1/10 - import BVA data');
        EEG = pop_loadbv(datafolder, filename);
        [ALLEEG, EEG, ~] = pop_newset(ALLEEG, EEG, 0,'setname','temp','gui','off'); 
        
        %% add channel locations
        disp('Step 2/10 - add channel coordinates');
        EEG = eeg_checkset(EEG);
        EEG=pop_chanedit(EEG, 'lookup','standard_1005.elc');
        %[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
        
        %% save raw data in eeglab format
        disp('Step 3/10 - save raw data in eeglab format');
        EEG = eeg_checkset(EEG);
        EEG = pop_saveset(EEG, 'filename',[basename '_01_raw.set'], ...
                               'filepath',datafolder);

        %% rename TR markers
        disp('Step 4/10 - rename TR markers');
        for i = 1:length(EEG.event)
            if strcmp(EEG.event(i).type(1:4), 'T  1')
                EEG.event(i).type = 'T1';
            end
        end
        
        %% remove MRI gradient artifacts
        disp('Step 5/10 = remove gradient artifacts (this may take a while...)');
        EEG = eeg_checkset(EEG);
        [EEG, ~] = pop_fmrib_fastr(EEG, 70, 4, 31, 'T1', 0, 0, 0, [], [], [], 32, 'auto');
        
        %% downsample
        disp('Step 6/10 - downsample data');
        EEG = eeg_checkset(EEG);
        EEG = pop_resample(EEG, newSamplingRate);
        
        %% detect QRS
        disp('Step 7/10 - detect R spikes');
        EEG = eeg_checkset(EEG);
        EEG = pop_fmrib_qrsdetect(EEG, 32, 'qrs', 'no');
        
        %% remove cardioballistic artifacts
        disp('Step 8/10 - remove cardioballistic artifacts');
        EEG = eeg_checkset(EEG);
        EEG = pop_fmrib_pas(EEG,'qrs','obs',3);
        
        %% filtering
        disp('Step 9/10 - filter data');
        EEG = eeg_checkset(EEG);
        EEG = pop_eegfiltnew(EEG, 'locutoff',filterCutOff(1),'hicutoff',filterCutOff(2),'plotfreqz',0,'channels',{'Fp1','Fp2','F3','F4','C3','C4','P3','P4','O1','O2','F7','F8','T7','T8','P7','P8','Fz','Cz','Pz','Oz','FC1','FC2','CP1','CP2','FC5','FC6','CP5','CP6','TP9','TP10','POz'});
        [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'setname','temp', 'gui' ,'off'); 
        [~, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);

        %% save prepped data
        disp('Step 10/10 - save data prepped 4 ICA');
        EEG = eeg_checkset(EEG);
        pop_saveset(EEG, 'filename',[basename '_prepped4ICA.set'],'filepath',datafolder);

        %% generate logfile
        logText = strcat('logfile for ssv4att_MRI: prepping 4 ICA\n', ...
                   'date_time: ', string(datetime()), '\n', ...
                   'participant: ', basename, '\n', ...
                   'new sampling rate: ', int2str(newSamplingRate), '\n', ...
                   'filter cut-offs: ', int2str(filterCutOff));
        fID = fopen([datafolder '/' basename '.log1.txt'], 'w');
        fprintf(fID, logText);
        fclose(fID);
    
   %% run ICA
        disp('Final Step - run ICA');
        EEG = pop_runica(EEG,'icatype','sobi','chanind',1:31);    
        EEG = eeg_checkset(EEG);
        pop_saveset(EEG, 'filename',[basename '_afterICA.set'], ...
                         'filepath',datafolder);

end
