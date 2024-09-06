function [EEG, EEG_pleasant, EEG_neutral, EEG_unpleasant, EEG_miso] =  natsounds_prepro2(datapath, logpath)

     %read data into eeglab
     EEG = pop_readegi(datapath, [],[],'auto');
     EEG=pop_chanedit(EEG, 'load',{'/home/laura/Documents/GitHub/csea-lab/Libas/4data/HCGSNSensorPostionFiles/GSN-HydroCel-128.sfp','filetype','autodetect'});
     EEG.setname='temp';
     EEG = eeg_checkset( EEG );
     
     % bandpass filter
     EEG = pop_eegfiltnew(EEG,3,55);
     EEG = eeg_checkset( EEG );

     % eye blink correction with Biosig
     [R,S2] = regress_eog(double(EEG.data'), 1:128, sparse([125,128,25,127,8,126],[1,1,2,2,3,3],[1,-1,1,-1,1,-1]));
     EEG.data = single(S2');
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

      EEG.event(find(eventsdiscard)) = [];

     % now we replace the DIN4 with the condition  
      counter = 1; 
      for x = 1:size(EEG.event,2) %  
          if strcmp(EEG.event(x).type, 'DIN4')
              EEG.event(x).type = num2str(conditionvec(counter)); 
              counter = counter+1; 
          end
      end


     % Epoch the EEG data 
     EEG_allcond = pop_epoch( EEG, {  '1' '2' '3' '4' }, [-0.6 6], 'newname', 'allcond', 'epochinfo', 'yes');
     EEG_allcond = eeg_checkset( EEG_allcond );
     EEG_allcond = pop_rmbase( EEG_allcond, [-600 0] ,[]);
     inmat3d = double(EEG_allcond.data);
     [outmat3dp, interpsensmat] = scadsAK_3dchan(inmat3d, EEG_allcond.chanlocs); 
     EEG_allcond.data = single(outmat3dp); 
     EEG_allcond = eeg_checkset( EEG_allcond );
     [EEG_allcond, reject_all] = pop_autorej(EEG_allcond, 'nogui','on', 'maxrej', 30,'startprob',4 ,'eegplot','off');
     EEG_allcond = eeg_checkset( EEG_allcond );

     % pleasant
     EEG_pleasant = pop_selectevent( EEG_allcond,  'type', '1' );
     EEG_pleasant = eeg_checkset( EEG_pleasant );
     % neutral
     EEG_neutral = pop_selectevent( EEG_allcond,  'type', '2' );
     EEG_neutral = eeg_checkset( EEG_neutral );  
     % unpleasant
     EEG_unpleasant = pop_selectevent( EEG_allcond,  'type', '3' );
     EEG_unpleasant = eeg_checkset( EEG_unpleasant );
     % miso
     EEG_miso = pop_selectevent( EEG_allcond,  'type', '4' );
     EEG_miso = eeg_checkset( EEG_miso );
    

     save([datapath(1:end-4) '.cleaneeg.mat'], 'EEG_pleasant', 'EEG_neutral', 'EEG_unpleasant', 'EEG_miso', '-mat')

