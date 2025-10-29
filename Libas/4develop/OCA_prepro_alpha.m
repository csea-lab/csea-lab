function [EEG_allcond] =  OCA_prepro_alpha(datapath)
% datapath is name of .raw file, this function rins only for 129channel EGI data

    stringlength = 8; 
    timevec = [-2 60]; 
    filtercoeffHz = [2 30];
    filtord = [4 11]; 
    sfpfilename = 'GSN-HydroCel-256.sfp'; 
    ecfgfilename = 'HC1-256.ecfg';
    eyecorrflag = 1; 
    conditions2select = {'1' '2'}; 

    thresholdChanTrials = 2.5; 
    thresholdTrials = 1.25;
    thresholdChan = 2.2;
    
    basename  = datapath(1:stringlength); 

     %read data into eeglab
     EEG = pop_readegi(datapath, [],[],'auto');
     EEG=pop_chanedit(EEG, 'load',{sfpfilename,'filetype','autodetect'});
     EEG.setname='temp';
     EEG = eeg_checkset( EEG );

     % downsample to 500 Hz
     EEG = pop_resample( EEG, 500);
     EEG = eeg_checkset( EEG );
     
     % highpass filter
     if filtercoeffHz(1) > 0
         [B,A] = butter(filtord(1),filtercoeffHz(1)/(EEG.srate/2), 'high');
         filtereddata = filtfilt(B,A,double(EEG.data)')'; %
         EEG.data =  single(filtereddata);
         disp('highpass filter')
     end

     % lowpass filter
     if filtercoeffHz(2) > 0
         [B,A] = butter(filtord(2),filtercoeffHz(2)/(EEG.srate/2));
         filtereddata = filtfilt(B,A,double(EEG.data)')'; %
         EEG.data =  single(filtereddata);
         disp('lowpass filter')
     end

     EEG = eeg_checkset( EEG );

     if eyecorrflag
         % eye blink correction with Biosig
         if size(EEG.data, 1)==128
             [~,S2] = regress_eog(double(EEG.data'), 1:128, sparse([125,128,25,127,8,126],[1,1,2,2,3,3],[1,-1,1,-1,1,-1]));
         elseif size(EEG.data, 1)==256
             [~,S2] = regress_eog(double(EEG.data'), 1:256, sparse([252,226,37,241,18,238],[1,1,2,2,3,3],[1,-1,1,-1,1,-1]));
         end
     EEG.data = single(S2');
     EEG = eeg_checkset( EEG );
     end
    
     % conditions are always the same 1 = eyes closed, 2 eyes open
     conditionvec = [1 2 1 2]; 

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
     EEG_allcond = pop_epoch( EEG,  {'1' '2'}, timevec, 'newname', 'allcond', 'epochinfo', 'yes');
     EEG_allcond = eeg_checkset( EEG_allcond );
     EEG_allcond = pop_rmbase( EEG_allcond, [-100 0] ,[]);
     inmat3d = double(EEG_allcond.data);

     % find generally bad channels
      disp('artifact handling: channels')
     [outmat3d, BadChanVec] = scadsAK_3dchan(inmat3d, ecfgfilename, thresholdChan); 
     EEG_allcond.data = single(outmat3d); 
     EEG_allcond = eeg_checkset( EEG_allcond );

    % find bad channels in epochs
      disp('artifact handling: channels in epochs')
    [ outmat3d, badindexmat] = scadsAK_3dtrialsbychans(outmat3d, thresholdChanTrials, ecfgfilename);
     EEG_allcond.data = single(outmat3d);
     EEG_allcond = eeg_checkset(EEG_allcond);

     %% ICA
        EEG_allcond = pop_runica(EEG_allcond,'icatype','sobi','chanind',1:256);    
        EEG_allcond = eeg_checkset(EEG_allcond);
        pop_saveset(EEG_allcond, 'filename',[basename '_ICA.set'], 'filepath',pwd);
        
      %% create output file for artifact summary. 
      artifactlog.globalbadchans = BadChanVec;
      artifactlog.epochbadchans = badindexmat;
%      artifactlog.badtrialstotal = badindexvec; 
      artifactlog.filtercoeffHz = filtercoeffHz; 
      artifactlog.filtord = filtord; 

    %% create single trial file for all conditions
     Mat3D = avg_ref_add3d(double(EEG_allcond.data));
     save([basename '.trls.g.mat'], 'Mat3D', '-mat')

     %% select conditions; compute and write output
     artifactlog.goodtrialsbycondition = []; % remaining artifact info by condition will be populated

    for con_index = 1:size(conditions2select,2)
  
     %select conditions   
     EEG_temp = pop_selectevent( EEG_allcond,  'type', conditions2select{con_index} );
     EEG_temp = eeg_checkset( EEG_temp );
     
     % compute ERPs
     ERPtemp = double(avg_ref_add(squeeze(mean(EEG_temp.data(:, :, 1:end), 3))));
     
     % compute single trial array in 3D
     Mat3D = avg_ref_add3d(double(EEG_temp.data));

     % save the ERP in emegs at format
      SaveAvgFile([basename '.at' conditions2select{con_index} '.ar'],ERPtemp,[],[], EEG.srate, [], [], [], [], abs(timevec(1) *EEG.srate)+1); 

      % save the single trial array in 3D
      save([basename '.trls.' conditions2select{con_index} '.mat'], 'Mat3D', '-mat')
   
      % complete artifact info
      artifactlog.goodtrialsbycondition = [artifactlog.goodtrialsbycondition; size(EEG_temp.data, 3)];

    end

   %% save the artifact info
     save([basename '.artiflog.mat'], 'artifactlog', '-mat')


    



     
