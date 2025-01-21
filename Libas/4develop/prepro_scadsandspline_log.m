function [EEG_allcond] =  prepro_scadsandspline_log(datapath, logpath, convecfun, stringlength, conditions2select, timevec, filtercoeffHz, filtord, skiptrials, sfpfilename, ecfgfilename)
% datapath is name of .raw file, this function rins only for 129channel EGI data
% logpath is the name .dat file
% convecfun is the name of a function that takes a dat file and generates a
% condition vector
% stringlength is the number of characters from the raw basename to be used
% for output names
% skiptrials is the starting point for any trials (skip trials at the beginning in learning studies) 
% conditions2select is a cell array with condition names that we want e.g. {  '21' '22' '23' '24' }
% timevec is time in seconds for segmentation e.g. [-0.6 3.802]
% filtercoeffHz could be [1 30] for a 1 to 30 Hz bandpass filter - it *IS*
% in Hertz
% filtord is the order of the filter, if funny results make smaller, 4 is
% good as a starting point. 
% the final two inputs are filenames for electrode confis files in .sfp
% format and ecfg format. make sure these are in the matlab path

    thresholdChanTrials = 2.5; 
    thresholdTrials = 1.25;
    thresholdChan = 2.5;
    
    % skip a few initial trials tyo accomodate learning experiments
    if nargin < 9, skiptrials = 1; end % default no initial trials are skipped

    basename  = datapath(1:stringlength); 

     %read data into eeglab
     EEG = pop_readegi(datapath, [],[],'auto');
     EEG=pop_chanedit(EEG, 'load',{sfpfilename,'filetype','autodetect'});
     EEG.setname='temp';
     EEG = eeg_checkset( EEG );
     

     % highpass filter
     if filtercoeffHz(1) > 0
     [B,A] = butter(filtord(1),filtercoeffHz(1)/(EEG.srate/2), 'high');
     filtereddata = filtfilt(B,A,double(EEG.data)')'; % 
     EEG.data =  single(filtereddata); 
     end
   
     % lowpass filter
     if filtercoeffHz(2) > 0
     [B,A] = butter(filtord(2),filtercoeffHz(2)/(EEG.srate/2));
     filtereddata = filtfilt(B,A,double(EEG.data)')'; % 
     EEG.data =  single(filtereddata); 
     end

     EEG = eeg_checkset( EEG );

     % eye blink correction with Biosig
     if size(EEG.data, 1)==128
         [~,S2] = regress_eog(double(EEG.data'), 1:128, sparse([125,128,25,127,8,126],[1,1,2,2,3,3],[1,-1,1,-1,1,-1]));
     elseif size(EEG.data, 1)==256
         [~,S2] = regress_eog(double(EEG.data'), 1:256, sparse([252,226,37,241,18,238],[1,1,2,2,3,3],[1,-1,1,-1,1,-1]));
     end

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
     EEG_allcond = pop_rmbase( EEG_allcond, [-100 0] ,[]);
     inmat3d = double(EEG_allcond.data);

     % find generally bad channels
     [outmat3d, BadChanVec] = scadsAK_3dchan(inmat3d, ecfgfilename, thresholdChan); 
     EEG_allcond.data = single(outmat3d); 
     EEG_allcond = eeg_checkset( EEG_allcond );

    % find bad channels in epochs
    [ outmat3d, badindexmat] = scadsAK_3dtrialsbychans(outmat3d, thresholdChanTrials, ecfgfilename);
     EEG_allcond.data = single(outmat3d);
     EEG_allcond = eeg_checkset( EEG_allcond );

      % find bad trials and reject in epochs
    [ outmat3d, badindexvec, NGoodtrials ] = scadsAK_3dtrials(outmat3d, thresholdTrials);
      EEG_allcond = pop_select( EEG_allcond, 'notrial', badindexvec);


      %% create output file for artifact summary. 
      artifactlog.globalbadchans = BadChanVec;
      artifactlog.epochbadchans = badindexmat;
      artifactlog.badtrialstotal = badindexvec; 
      artifactlog.filtercoeffHz = filtercoeffHz; 
      artifactlog.filtord = filtord; 
      %artifactlog.badtrialsbycondition = [size(EEG_21.data, 3),size(EEG_22.data, 3), size(EEG_23.data, 3),size(EEG_24.data, 3)];

      %% select conditions; compute and write output
     artifactlog.goodtrialsbycondition = []; % remaining artifact info by condition will be populated

    for con_index = 1:size(conditions2select,2)
  
     %select conditions   
     EEG_temp = pop_selectevent( EEG_allcond,  'type', conditions2select{con_index} );
     EEG_temp = eeg_checkset( EEG_temp );
     
     % compute ERPs
     ERPtemp = double(avg_ref_add(squeeze(mean(EEG_temp.data(:, :, skiptrials:end), 3))));
     
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


    



     
