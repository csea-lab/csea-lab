function [EEG_allcond] =  ClarkHillyardPipeline(datapath, logpath, convecfun, stringlength, conditions2select, timevec, filtercoeffHz, filtord, skiptrials, sfpfilename, ecfgfilename, eyecorrflag)
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

    thresholdChan = 2.0;
    thresholdVoltage = 50;

    % skip a few initial trials tyo accomodate learning experiments
    if nargin < 9, skiptrials = 1; end % default no initial trials are skipped

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
    
     %read conditions from log file;
     conditionvec = feval(convecfun, logpath);

      % now get rid of excess event markers, if any.
      for indexlat = 1:size(EEG.event,2)
        markertimesinSP(indexlat) = EEG.event(indexlat).latency;
      end

      tempdiff1 = diff([0 markertimesinSP]);
      eventsend = markertimesinSP(tempdiff1>20);
      eventsdiscard = (tempdiff1<20);
      disp(['a total of ' num2str(length(eventsend)) ' markers were found in the file'])

      EEG.event(find(eventsdiscard)) = [];

      % collect ITIs for Ajar
      for eventindex = 1:4800-1
       ITIdistribution(eventindex) =  (EEG.event(eventindex+1).latency-EEG.event(1, eventindex).latency)-29; % account for sampling rate and way it was coded, plus one retrace
      end
      ITIdistribution = ITIdistribution(ITIdistribution<600); % rule out ITis between blocks  
      save('ITIdistribution.mat', 'ITIdistribution')

     % replace the DIN with the condition  
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
     disp('artifact handling: channels')
     [outmat3d, BadChanVec] = scadsAK_3dchan(inmat3d, ecfgfilename, thresholdChan); 
     EEG_allcond.data = single(outmat3d); 
     EEG_allcond = eeg_checkset( EEG_allcond );

      % find bad trials based on overall amplitude
       disp('artifact handling: trials by voltage')
       [ ~, badindexvec1, NGoodtrials ] = threshold_3dtrials(EEG_allcond.data, thresholdVoltage);
 
        % find bad trials based on eye channels
        disp('artifact handling: trials by eye artifact')
       horipair = [226, 252]; vertipair = [238, 10];
      [ ~, badindexvec2, ~ ] = reject_eye_3dtrials(inmat3d, horipair, vertipair, 30);

      % remove from dataset
       disp('removing bad trials')
      badindexvec = cat(1, badindexvec1, badindexvec2); 
       EEG_allcond = pop_select( EEG_allcond, 'notrial', unique(badindexvec));

     % throw out trials that occur just before and after a target/response
     targetepochindex = []; 
     for epochindex = 2:size(EEG_allcond.epoch,2)-1
         %find marker event for that segment
         reflatencyvec =  cell2mat(EEG_allcond.epoch(epochindex).eventlatency);
         eventindex = find(reflatencyvec==0);
         trialcondition = cell2mat(EEG_allcond.epoch(epochindex).eventtype(eventindex)); 
         if str2double(trialcondition) > 19
             targetepochindex = [targetepochindex epochindex-1 epochindex+1]; 
         end
     end
 
      EEG_allcond = pop_select( EEG_allcond, 'notrial', targetepochindex);
  
      %% create output file for artifact summary. 
      artifactlog.nGoodtrialthreshold = NGoodtrials; 
      artifactlog.filtercoeffHz = filtercoeffHz; 
      artifactlog.filtord = filtord; 
      artifactlog.BadChanVec = BadChanVec;
      artifactlog.BadtrialsVoltage = badindexvec1; 
      artifactlog.BadtrialsEye = badindexvec2;

      %% select conditions; compute and write output
      artifactlog.goodtrialsbycondition = []; % remaining artifact info by condition will be populated

      disp('save output to disk')

      for con_index = 1:size(conditions2select,2)

          %select conditions
          EEG_temp = pop_selectevent( EEG_allcond,  'type', conditions2select{con_index} );
          EEG_temp = eeg_checkset( EEG_temp );

          % compute ERPs
          ERPtemp = double(squeeze(mean(EEG_temp.data(:, :, skiptrials:end), 3)));

          % reference to mastoids
          ERPref = LB3_reref_EEG_add(ERPtemp, [189 190 201 191]);

          % save the ERP in emegs at format
          SaveAvgFile([basename '.at' conditions2select{con_index} '.mr'],ERPref,[],[], EEG.srate, [], [], [], [], abs(timevec(1) *EEG.srate)+1);

          % correct with ADJAR and save as separate files by condition
          [correctedERP, ~, ~] = Adjar(ERPref, ITIdistribution, 151, 225);
           SaveAvgFile([basename '.adjar.at' conditions2select{con_index} '.mr'],correctedERP,[],[], EEG.srate, [], [], [], [], abs(timevec(1) *EEG.srate)+1);

          % complete artifact info
          artifactlog.goodtrialsbycondition = [artifactlog.goodtrialsbycondition; size(EEG_temp.data, 3)];

      end



   %% save the artifact info
     save([basename '.artiflog.mat'], 'artifactlog', '-mat')


    



     
