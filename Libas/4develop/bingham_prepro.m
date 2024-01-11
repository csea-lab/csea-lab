function [EEG, EEG_happy, EEG_angry, EEG_sad, string, checktimevec] =  bingham_prepro (datapath, logpath)

     %read data into eeglab
     EEG = pop_fileio(datapath);
     EEG.setname='temp';
     EEG = eeg_checkset( EEG );
     
     % bandpass filter
     EEG = pop_eegfiltnew(EEG,3,34);
     EEG = eeg_checkset( EEG );bingham_prepro.m
bingham_postpro.m
bingham_findgoodtrig.m
bingham_prostpro.m
bingham_calcspec.m
bingham_avgsubj.m

     % add electrode locations
     % this should work universally:
     temppath = which( 'eeglab');
     [filepath,~] = fileparts(temppath); 
     EEG=pop_chanedit(EEG, 'lookup', [filepath '/plugins/dipfit/standard_BESA/standard-10-5-cap385.elp']);
     % OR: swap for different labs/computers
     % EEG=pop_chanedit(EEG, 'lookup','/Users/admin/Documents/eeglab2022.1/plugins/dipfit/standard_BESA/standard-10-5-cap385.elp');
      % EEG=pop_chanedit(EEG, 'lookup','/Users/andreaskeil/matlab_as/eeglab2019_0/plugins/dipfit/standard_BESA/standard-10-5-cap385.elp');
     EEG = eeg_checkset( EEG );
    
     %read conditions from log file; there should be 90 trials logged. the
     %code adds two markers 8 and 9 at the top for the resting (eyes
     %open/closed) and two at the bottom for trigs sent at the end. 
      conditionvec = bingham_logread(logpath);

      % now replace the correct event markers with the actual events, they
      % are found by bingham_findgoodtrig.m

      [string, checktimevec] = bingham_findgoodtrig(EEG);
      if checktimevec(1) < 60000
          conditionvec = [0; conditionvec]; 
          maxcount = 94;
      else 
          maxcount = 93;
      end

      disp(['a total of ' num2str(length(checktimevec)+1) ' markers of type ' string ' were found in the file'])

      counter =1; 
      for x = 1:size(EEG.event,2) %  
          if strcmp(EEG.event(x).type, string) && counter < maxcount+1 
              EEG.event(x).type = num2str(conditionvec(counter)); 
              counter = counter+1; 
          end
      end

     % happy
     EEG_happy = pop_epoch( EEG, {  '1'  }, [-0.6 5.6], 'newname', 't epochs', 'epochinfo', 'yes');
     EEG_happy = eeg_checkset( EEG_happy );
     EEG_happy = pop_rmbase( EEG_happy, [-600 0] ,[]);
     EEG_happy = eeg_checkset( EEG_happy );
     [EEG_happy, reject_happy] = pop_autorej(EEG_happy, 'nogui','on','threshold',200, 'maxrej', 15,'startprob',3, 'electrodes',[1:31] ,'eegplot','off');
     EEG_happy = eeg_checkset( EEG_happy );
     EEG_happy = pop_rejepoch( EEG_happy, reject_happy,0);
     

     % angry
     EEG_angry = pop_epoch( EEG, {  '2'  }, [-0.6 5.6], 'newname', 't epochs', 'epochinfo', 'yes');
     EEG_angry = eeg_checkset( EEG_angry );
     EEG_angry = pop_rmbase( EEG_angry, [-600 0] ,[]);
     EEG_angry = eeg_checkset( EEG_angry );
     [EEG_angry, reject_angry] = pop_autorej(EEG_angry, 'nogui','on','threshold',200, 'maxrej', 15, 'startprob',3, 'electrodes',[1:31] ,'eegplot','on');
     EEG_angry = eeg_checkset( EEG_angry );
     EEG_angry = pop_rejepoch( EEG_angry, reject_angry,0);
     
     % sad
     EEG_sad = pop_epoch( EEG, {  '3'  }, [-0.6 5.6], 'newname', 't epochs', 'epochinfo', 'yes');
     EEG_sad = eeg_checkset( EEG_sad );
     EEG_sad = pop_rmbase( EEG_sad, [-600 0] ,[]);
     EEG_sad = eeg_checkset( EEG_sad );
     [EEG_sad, reject_sad] = pop_autorej(EEG_sad, 'nogui','on','threshold',200, 'maxrej', 15,'startprob',3, 'electrodes',[1:31] ,'eegplot','off');
     EEG_sad = eeg_checkset( EEG_sad );
     EEG_sad = pop_rejepoch( EEG_sad, reject_sad,0);

     save([logpath(1:end-4) '.cleaneeg.mat'],  'EEG_angry', 'EEG_sad', 'EEG_happy', '-mat')

