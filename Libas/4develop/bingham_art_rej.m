% [outputs] = functionName(inputs)
function [EEG_out, artif_out] = bingham_art_rej(EEG_in, params)

EEG_out = EEG_in; 

thresholdChanTrials = params(1); 
thresholdTrials = params(2); 
thresholdChan = params(3); 

tempzeros = zeros(34, size(EEG_in.data, 2), size(EEG_in.data, 3)); 

% params defaults: params = [2.5 1.25 2.5]

ecfgfilename = 'bingham31.ecfg';

  % find generally bad channels
      disp('artifact handling: channels')
     [outmat3d, BadChanVec] = scadsAK_3dchan(EEG_in.data(1:31,:,:), ecfgfilename, thresholdChan); 
     tempzeros(1:31,:, :) = outmat3d; 
     EEG_out.data = single(tempzeros); 
     EEG_out = eeg_checkset(EEG_out);
     

    % find bad channels in epochs
      disp('artifact handling: channels in epochs')
    [ outmat3d, badindexmat] = scadsAK_3dtrialsbychans(outmat3d, thresholdChanTrials, ecfgfilename);
     tempzeros(1:31,:, :) = outmat3d; 
     EEG_out.data = single(tempzeros);
     EEG_out = eeg_checkset( EEG_out );


      % find bad trials and reject in epochs
      disp('artifact handling: epochs')
    [ ~, badindexvec, ~ ] = scadsAK_3dtrials(outmat3d, thresholdTrials);
      EEG_out = pop_select( EEG_out, 'notrial', badindexvec);

      artif_out.BadChanVec = BadChanVec; 
      artif_out.badindexmat = badindexmat; 
      artif_out.badtrials = badindexvec;  