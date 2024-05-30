function [  EEG_CerThreat,   EEG_PoThreat,  EEG_Safe] =  eeglab_EGI129_prepro (datapath, logpath, flag180)


    %read data into eeglab
     EEG = pop_fileio(datapath, 'dataformat','auto');
     EEG.setname='temp';
     EEG = eeg_checkset( EEG );
     
     % bandpass filter
     EEG = pop_eegfiltnew(EEG, 'locutoff',3,'hicutoff',34,'plotfreqz',1);
     EEG = eeg_checkset( EEG );

     % add electrode locations
     EEG=pop_chanedit(EEG, 'load',{'GSN-HydroCel-129.sfp' 'filetype' 'autodetect'},'changefield',{132 'datachan' 0},'setref',{'132' 'Cz'});
     EEG = eeg_checkset( EEG );
     [~,S2] = regress_eog(double(EEG.data'), 1:129, sparse([125,128,25,127,8,126],[1,1,2,2,3,3],[1,-1,1,-1,1,-1]));
     EEG.data = (S2');

     %read conditions from log file
%      conditionvec= getcon_wurz(logpath);
conditionvec= readtable(logpath);
conditionvec = table2array(conditionvec); 
     %% now the trigger issue, har har
     for index1 = 1:length(EEG.event)
        temptrigs(index1) = EEG.event(index1).latency;
     end
        
        newtrigvec = []; 
        indiceswithtrigs = find(diff(temptrigs) > 9); 
        newtrigvec_temp = temptrigs(indiceswithtrigs+1);
        newtrigvec = [temptrigs(1); newtrigvec_temp']; 


     % replace trigger structures in EEG structure with actual triggers
       
         
%         if flag180
%             newtrigvec = newtrigvec(1:180);
%         end

        if flag180
            newtrigvec = newtrigvec(1:180);
        else
            EEG_temp = pop_epoch( EEG, {  'DIN1'  }, [-0.4 10], 'newname', 't epochs', 'epochinfo', 'yes');
            EEG_temp = pop_rmbase( EEG_temp, [-400 0] ,[]);
            EEG_temp = eeg_checkset( EEG_temp);            
   
            for index2 = 1:length(EEG_temp.event)
                EEG_temp.event(index2).type = conditionvec(index2);
            end
        end

     % Certain Threat
      EEG_CerThreat = pop_epoch( EEG, {  '1'  }, [-0.4 10], 'newname', 't epochs', 'epochinfo', 'yes');
      EEG_CerThreat = eeg_checkset( EEG_CerThreat);
      EEG_CerThreat = pop_rmbase( EEG_CerThreat, [-400 0] ,[]);
      EEG_CerThreat = eeg_checkset( EEG_CerThreat);
      EEG_CerThreat = pop_autorej( EEG_CerThreat, 'nogui','on','threshold',100, 'maxrej', 20,'startprob',3, 'electrodes',[1:128] ,'eegplot','off');
      EEG_CerThreat = eeg_checkset( EEG_CerThreat);
     
     % Potential Threat
      EEG_PoThreat = pop_epoch( EEG, {  '2'  }, [-0.4 10], 'newname', 't epochs', 'epochinfo', 'yes');
      EEG_PoThreat = eeg_checkset( EEG_PoThreat);
      EEG_PoThreat = pop_rmbase( EEG_PoThreat, [-400 0] ,[]);
      EEG_PoThreat = eeg_checkset( EEG_PoThreat);
      EEG_PoThreat = pop_autorej( EEG_PoThreat, 'nogui','on','threshold',100, 'maxrej', 20,'startprob',3, 'electrodes',[1:128] ,'eegplot','off');
      EEG_PoThreat = eeg_checkset( EEG_PoThreat);

     % Safe
      EEG_Safe = pop_epoch( EEG, {  '3'  }, [-0.4 10], 'newname', 't epochs', 'epochinfo', 'yes');
      EEG_Safe = eeg_checkset(EEG_Safe);
      EEG_Safe = pop_rmbase(EEG_Safe, [-400 0] ,[]);
      EEG_Safe = eeg_checkset(EEG_Safe);
      EEG_Safe = pop_autorej(EEG_Safe, 'nogui','on','threshold',100, 'maxrej', 20,'startprob',3, 'electrodes',[1:128] ,'eegplot','off');
      EEG_Safe = eeg_checkset(EEG_Safe);


     save([logpath(1:end-4) '.cleaneeg.mat'],  'EEG_PoThreat', 'EEG_Safe', 'EEG_CerThreat', '-mat')

