function [EEG_allcond] =  prepro_scadsandspline(datapath, logpath, convecfun, stringlength, conditions2select, timevec, skiptrials)
% datapath is name of .raw file, this function rins only for 129channel EGI data
% logpath is the name .dat file
% convecfun is the name of a function that takes a dat file and generates a
% condition vector
% stringlength is the number of characters from the raw basename to be used
% for output names
% skiptrials is the starting point for any trials (skip trials at the beginning in learning studies) 
% conditions2select is a cell array with condition names that we want e.g. {  '21' '22' '23' '24' }
% timevec is time in seconds for segmentation e.g. [-0.6 3.802]

    thresholdChanTrials = 2.5; 
    thresholdTrials = 1.25;
    thresholdChan = 2.5;
    
    % skip a few initial trials tyo accomodate learning experiments
    if nargin < 7, skiptrials = 1; end % default no initial trials are skipped

    basename  = datapath(1:stringlength); 

     %read data into eeglab
     EEG = pop_readegi(datapath, [],[],'auto');
     EEG=pop_chanedit(EEG, 'load',{'GSN-HydroCel-129.sfp','filetype','autodetect'});
     EEG.setname='temp';
     EEG = eeg_checkset( EEG );
     
     % bandpass filter
     filtord = 5; 
     [B,A] = butter(filtord,[3 30]/(EEG.srate/2));
     filtereddata = filtfilt(B,A,double(EEG.data)')'; % 
     EEG.data =  single(filtereddata); 
     EEG = eeg_checkset( EEG );

     % eye blink correction with Biosig
     [~,S2] = regress_eog(double(EEG.data'), 1:128, sparse([125,128,25,127,8,126],[1,1,2,2,3,3],[1,-1,1,-1,1,-1]));
     EEG.data = single(S2');
     EEG = eeg_checkset( EEG );
    
     %read conditions from log file;
     conditionvec = feval(convecfun, logpath);

      % now get rid of excess event markers 
      for indexlat = 1:size(EEG.event,2)
        markertimesinSP(indexlat) = EEG.event(indexlat).latency;
      end

      tempdiff1 = diff([0 markertimesinSP]);

      eventsend = markertimesinSP(tempdiff1>20);

      eventsdiscard = (tempdiff1<20);

      disp(['a total of ' num2str(length(eventsend)) ' markers were found in the file'])

      EEG.event(find(eventsdiscard)) = [];

     % now we replace the DIN with the condition  
      counter = 1; 
      for x = 1:size(EEG.event,2) %  
          if strcmp(EEG.event(x).type(1:3), 'DIN')
              EEG.event(x).type = num2str(conditionvec(counter)); 
              counter = counter+1; 
          end
      end

     % Epoch the EEG data 
     EEG_allcond = pop_epoch( EEG, conditions2select, timevec, 'newname', 'allcond', 'epochinfo', 'yes');
     EEG_allcond = eeg_checkset( EEG_allcond );
     EEG_allcond = pop_rmbase( EEG_allcond, [-600 0] ,[]);
     inmat3d = double(EEG_allcond.data);

     % find generally bad channels
     [outmat3d, BadChanVec] = scadsAK_3dchan(inmat3d, 'HC1-128.ecfg', thresholdChan); 
     EEG_allcond.data = single(outmat3d); 
     EEG_allcond = eeg_checkset( EEG_allcond );

    % find bad channels in epochs
    [ outmat3d, badindexmat] = scadsAK_3dtrialsbychans(outmat3d, thresholdChanTrials, 'HC1-128.ecfg');
     EEG_allcond.data = single(outmat3d);
     EEG_allcond = eeg_checkset( EEG_allcond );

      % find bad trials and reject in epochs
    [ outmat3d, badindexvec, NGoodtrials ] = scadsAK_3dtrials(outmat3d, thresholdTrials);
      EEG_allcond = pop_select( EEG_allcond, 'notrial', badindexvec);


      %% create output file for artifact summary. 
      artifactlog.globalbadchans = BadChanVec;
      artifactlog.epochbadchans = badindexmat;
      artifactlog.badtrialstotal = badindexvec; 
      %artifactlog.badtrialsbycondition = [size(EEG_21.data, 3),size(EEG_22.data, 3), size(EEG_23.data, 3),size(EEG_24.data, 3)];

     %% the artifact info
     save([basename '.artiflog.mat'], 'artifactlog', '-mat')






    



     
