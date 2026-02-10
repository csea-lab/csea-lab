function [EEG_allcond] =  blinkrate_prepro_pipeline(datapath, logpath, convecfun, stringlength, conditions2select, timevec, filtercoeffHz, filtord, skiptrials, sfpfilename, ecfgfilename, eyecorrflag, DINselect)
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
% two inputs are filenames for electrode confis files in .sfp
% format and ecfg format. make sure these are in the matlab path
% eyecorrflag toggles biosig toolbox regression eye artifact handling
% DINselect selects a specific digital input, e.g. 'DIN4' 

    thresholdChanTrials = 2.5; 
    thresholdTrials = 1.25;
    thresholdChan = 2.5;
    
    % skip a few initial trials tyo accomodate learning experiments
    if nargin < 9, skiptrials = 1; end % default no initial trials are skipped
    if nargin < 13, DINselect = []; end % default all DINs are recorded in the data

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

     % leftVEOG = 241 and 37
    % right VEOG = 238 and 18

    
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
      if isempty(DINselect)
          for x = 1:size(EEG.event,2) %
              if strcmp(EEG.event(x).type(1:3), 'DIN')
                  EEG.event(x).type = num2str(conditionvec(counter));
                  counter = counter+1;
              end
          end
      else
          for x = 1:size(EEG.event,2) %
              if strcmp(EEG.event(x).type(1:4), DINselect)
                  EEG.event(x).type = num2str(conditionvec(counter));
                  counter = counter+1;
              end
          end
      end

     % Epoch the EEG data 
     EEG_allcond = pop_epoch( EEG, conditions2select, timevec, 'newname', 'allcond', 'epochinfo', 'yes');
     EEG_allcond = eeg_checkset( EEG_allcond );
     EEG_allcond = pop_rmbase( EEG_allcond, [-100 0] ,[]);
     inmat3d = double(EEG_allcond.data);


    %% create single trial file for all conditions
     Mat3D = avg_ref_add3d(double(EEG_allcond.data));
     save([basename '.trls.g.mat'], 'Mat3D', '-mat')

     %% select conditions; compute and write output

    for con_index = 1:size(conditions2select,2)
  
     %select conditions   
     EEG_temp = pop_selectevent( EEG_allcond,  'type', conditions2select{con_index} );
     EEG_temp = eeg_checkset( EEG_temp );
     
     % compute ERPs
     ERPtemp = double(avg_ref_add(squeeze(mean(EEG_temp.data(:, :, skiptrials:end), 3))));
     
     % compute single trial array in 3D
   
     % here:  compute the VEOG for both eyes

     % with those, find blinks in each trial 
     

      % save the single trial array in 3D
      save([basename '.trls.' conditions2select{con_index} '.mat'], 'Mat3D', '-mat')
   


    end

   %% save the artifact info
     save([basename '.artiflog.mat'], 'artifactlog', '-mat')


    



     
