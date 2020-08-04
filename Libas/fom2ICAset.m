% function for running ICA on fom to find HR


appfilemat = filemat; 

for loopindex = 1 : size(appfilemat,1); 
    
    filepath = deblank(appfilemat(loopindex,:)); 
      
        outmat = app2mat(filepath, 0); 
        
        EEG = pop_importdata('dataformat','array','nbchan',129,'data','outmat','setname','test2','srate',500,'pnts',2301,'xmin',0);

        EEG = eeg_checkset( EEG );

        EEG=pop_chanedit(EEG, 'lookup','/Users/andreaskeil/matlab_as/eeglab14_1_2b/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp','load',{'/Users/andreaskeil/As_Docs/4workshops/Herzliya_ssvepWorkshop/code/Libas_light/4data/HCL_EGI129.ced' 'filetype' 'autodetect'});

        EEG = eeg_checkset( EEG );

        EEG = pop_runica(EEG, 'icatype' , 'SOBI');
        
        EEG = eeg_checkset( EEG );
        
        EEG = pop_saveset(EEG, 'filepath', [filepath '.temp']);
        
%         pop_eegplot( EEG, 0, 1, 1);
% 
%         pause

fclose('all');

end
