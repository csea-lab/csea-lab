% [outputs] = functionName(inputs)
% function outmat3d = bingham_new_prepro

thresholdChanTrials = 2.5; 
    thresholdTrials = 1.25;
    thresholdChan = 2.5;

    ecfgfilename = 'bingham31.ecfg'
    inmat3d = (EEG_angry);


  % find generally bad channels
      disp('artifact handling: channels')
     [outmat3d, BadChanVec] = scadsAK_3dchan(inmat3d, ecfgfilename, thresholdChan); 
     EEG_allcond.data = single(outmat3d); 
     EEG_allcond = eeg_checkset( EEG_allcond );

    % find bad channels in epochs
      disp('artifact handling: channels in epochs')
    [ outmat3d, badindexmat] = scadsAK_3dtrialsbychans(outmat3d, thresholdChanTrials, ecfgfilename);
     EEG_allcond.data = single(outmat3d);
     EEG_allcond = eeg_checkset( EEG_allcond );

      % find bad trials and reject in epochs
      disp('artifact handling: epochs')
    [ outmat3d, badindexvec, NGoodtrials ] = scadsAK_3dtrials(outmat3d, thresholdTrials);
      EEG_allcond = pop_select( EEG_allcond, 'notrial', badindexvec);