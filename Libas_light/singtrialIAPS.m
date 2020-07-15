function [ fftamp ] = singtrialIAPS( rawfilemat, datfilemat)
%
for index = 1:size(rawfilemat,1); 
    
    EEGfilepath = deblank(rawfilemat(index,:));    
    datfilepath = deblank(datfilemat(index,:));
   
    % read picnums from dat file
    [picnum] = getpicnum_ssvepiaps(datfilepath);     
    
    % read EEG and do preprocessing
    EEG = pop_fileio(EEGfilepath);
    EEG = eeg_checkset( EEG );
    EEG = findtrigsEGI_eeglab(EEG);
    
    % filter the data
    temp = EEG.data'; 
    [fila,filb] = butter(4, 0.3); 
    temp2 = filtfilt(fila, filb, double(temp)); 
    [filaH,filbH] = butter(2, 0.04, 'high');
    temp3 =  filtfilt(filaH, filbH, temp2)'; 
    EEG.data = single(temp3);
    EEG = eeg_checkset( EEG );

    % channel locations
    EEG=pop_chanedit(EEG, 'load',{'GSN-HydroCel-129.sfp' 'filetype' 'autodetect'},'changefield',{132 'datachan' 0},'setref',{'132' 'Cz'});
    EEG = eeg_checkset( EEG );
    EEG = pop_epoch( EEG, [], [-.1  3.4], 'newname', 'test epochs', 'epochinfo', 'yes');    
    EEG = pop_rmbase( EEG, [-100     0]);
     
      % take care of bad channels
      [outmat3d, interpsensvec] = scadsAK_3dchan(EEG.data, EEG.chanlocs);
      EEG.data = single(outmat3d); 
      
      % ICA     
        EEG = pop_runica(EEG,  'icatype', 'sobi');
        EEG = eeg_checkset( EEG );
        warning('off');
        pop_topoplot(EEG,0, [1:64] ,'component topographies',[8 8] ,0,'electrodes','off');
        warning('off');
        componentsremove = input('enter vector with rejected components      ' )
         EEG = pop_subcomp( EEG, componentsremove, 0);
         outmat3d_aftertrial = EEG.data;
         outmat3d_aftertrialAR = avg_ref_add3d(outmat3d_aftertrial); 
         EEG.data = outmat3d_aftertrialAR; 
            
       % moving average
       
       for trial = 1:180      
           mat = squeeze(EEG.data(:, :, trial)); 
         [~, fftamp(:, trial)] = stead2singtrialsMat(mat, 0, 1:50, 101:850, 17.5, 250, 525);           
       end


end % loop over files

