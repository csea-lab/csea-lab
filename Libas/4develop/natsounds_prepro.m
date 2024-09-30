function [EEG, EEG_pleasant, EEG_neutral, EEG_unpleasant, EEG_miso] =  natsounds_prepro(datapath, logpath)

     %read data into eeglab
     EEG = pop_readegi(datapath, [],[],'auto');
     EEG=pop_chanedit(EEG, 'load',{'/home/laura/Documents/GitHub/csea-lab/Libas/4data/HCGSNSensorPostionFiles/GSN-HydroCel-128.sfp','filetype','autodetect'});
     EEG.setname='temp';
     EEG = eeg_checkset( EEG );
     
     % bandpass filter
     EEG = pop_eegfiltnew(EEG,3,55);
     EEG = eeg_checkset( EEG );
    
     %read conditions from log file; there should be 90 trials logged. the
     %code adds two markers 8 and 9 at the top for the resting (eyes
     %open/closed) and two at the bottom for trigs sent at the end. 
     conditionvec = getcon_natsounds(logpath);

      % now get rid fo excess even markers 
      for indexlat = 1:size(EEG.event,2)
        markertimesinSP(indexlat) = EEG.event(indexlat).latency;
      end

      tempdiff1 = diff([0 markertimesinSP]);

      eventsend = markertimesinSP(tempdiff1>20);

      eventsdiscard = (tempdiff1<20);

      disp(['a total of ' num2str(length(eventsend)) ' markers were found in the file'])


      for x = 1:size(EEG.event,2) %  
          if eventsdiscard(x) == 1, EEG.event(x).type = 'double'; 
          end
      end

     % now we replace the DIN4 with the condition  
      counter = 1; 
      for x = 1:size(EEG.event,2) %  
          if strcmp(EEG.event(x).type, 'DIN4')
              EEG.event(x).type = num2str(conditionvec(counter)); 
              counter = counter+1; 
          end
      end


     % pleasant
     EEG_pleasant = pop_epoch( EEG, {  '1'  }, [-0.6 6], 'newname', 'pleasant', 'epochinfo', 'yes');
     EEG_pleasant = eeg_checkset( EEG_pleasant );
     EEG_pleasant = pop_rmbase( EEG_pleasant, [-600 0] ,[]);
     inmat3d = double(EEG_pleasant.data);
     [outmat3dp, interpsensmat] = scadsAK_3dchan(inmat3d, EEG_pleasant.chanlocs); 
     EEG_pleasant.data = outmat3dp; 
     EEG_pleasant = eeg_checkset( EEG_pleasant );
     [EEG_pleasant, reject_pleasant] = pop_autorej(EEG_pleasant, 'nogui','on','threshold',150, 'maxrej', 30,'startprob',2 ,'eegplot','off');
     EEG_pleasant = eeg_checkset( EEG_pleasant );
%    EEG_pleasant = pop_rejepoch( EEG_pleasant, reject_pleasant,0); 
     

     % neutral
     EEG_neutral = pop_epoch( EEG, {  '2'  }, [-0.6 6], 'newname', 'neutral', 'epochinfo', 'yes');
     EEG_neutral = eeg_checkset( EEG_neutral );
     EEG_neutral = pop_rmbase( EEG_neutral, [-600 0] ,[]);
     inmat3d = double(EEG_neutral.data);
     [outmat3dn, interpsensmat] = scadsAK_3dchan(inmat3d, EEG_neutral.chanlocs); 
     EEG_neutral.data = outmat3dn;
     EEG_neutral = eeg_checkset( EEG_neutral );
     [EEG_neutral, reject_neutral] = pop_autorej(EEG_neutral, 'nogui','on','threshold',150, 'maxrej', 30, 'startprob',2, 'eegplot','off');
     EEG_neutral = eeg_checkset( EEG_neutral );
%    EEG_neutral = pop_rejepoch( EEG_neutral, reject_neutral,0);
     
     % unpleasant
     EEG_unpleasant = pop_epoch( EEG, {  '3'  }, [-0.6 6], 'newname', 'unpleasant', 'epochinfo', 'yes');
     EEG_unpleasant = eeg_checkset( EEG_unpleasant );
     EEG_unpleasant = pop_rmbase( EEG_unpleasant, [-600 0] ,[]);
     inmat3d = double(EEG_unpleasant.data);
     [outmat3du, interpsensmat] = scadsAK_3dchan(inmat3d, EEG_unpleasant.chanlocs); 
     EEG_unpleasant.data = outmat3du; 
     EEG_unpleasant = eeg_checkset( EEG_unpleasant );
     [EEG_unpleasant, reject_unpleasant] = pop_autorej(EEG_unpleasant, 'nogui','on','threshold',150, 'maxrej', 30,'startprob',2,'eegplot','off');
     EEG_unpleasant = eeg_checkset( EEG_unpleasant );
%    EEG_unpleasant = pop_rejepoch( EEG_unpleasant, reject_unpleasant,0);
     
     % miso
     EEG_miso = pop_epoch( EEG, {  '4'  }, [-0.6 6], 'newname', 'miso', 'epochinfo', 'yes');
     EEG_miso = eeg_checkset( EEG_miso );
     EEG_miso = pop_rmbase( EEG_miso, [-600 0] ,[]);
     inmat3d = double(EEG_miso.data);
     [outmat3dm, interpsensmat] = scadsAK_3dchan(inmat3d, EEG_miso.chanlocs); 
     EEG_miso.data = outmat3dm; 
     EEG_miso = eeg_checkset( EEG_miso );
     [EEG_miso, reject_miso] = pop_autorej(EEG_miso, 'nogui','on','threshold',150, 'maxrej', 30,'startprob',2, 'eegplot','off');
     EEG_miso = eeg_checkset( EEG_miso );
%    EEG_miso = pop_rejepoch( EEG_miso, reject_miso,0);

     save([datapath(1:end-4) '.cleaneeg.mat'], 'EEG_pleasant', 'EEG_neutral', 'EEG_unpleasant', 'EEG_miso', '-mat')

