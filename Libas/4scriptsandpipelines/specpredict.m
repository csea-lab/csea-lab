function [predictor,trialssVEP, corrmat] = specpredict(matfilepath,igfilepath, plotflag, featureflag)
% for a single subject, takes following INPUTS: 
% path to a file with single trial EEG, "matfilepath" 
% path to a file with trial indices of good trials, "igfilepath"
% a plotflag (1 or 0 ) to plot output (1) or not (0)
% one of the following "featureflags" which select a predictor that is
% related (correlated) with the single trial SSVEP amplitude. 
%
% with these inputs, the correlation between the predictor and SSVEP is computed for all sensors, 
% and for that subject. 
% Can be looped over subjects.
% Outputs: 
% predictor: the predictor for each trial
% trialssVEP :The visual cortical response for each trial
% corrmat: a matrix of the correlation between the two


% data file stuff
a = load(matfilepath); % loads that person's data and creates 3_D matrix variable outmat
outmat = a.outmat; 

% index file stuff
temp = dlmread(igfilepath, '\t'); % load the indices of the good trials
goodtrialindex = temp(2,:); % only the second row has indices, first row is header
dummy1 = find(goodtrialindex > 150); % finds the indices for indices (sorry) that are greater than 150
endofhab = min(dummy1); % finds the precise trial (of only the good ones) that is the end of habituation

% putting it together
habituationdata = outmat(:, :, 1:endofhab); % selects only habituation trials from the data

% calculate the power spectrum of the baseline, to be used in many of the
% below analyses; plot if flag is on. 
[trialspec, trialphase, freqs] = FFT_spectrum3D_singtrial(habituationdata, 1:500, 500);

if plotflag
    plot(freqs(1:50), squeeze(mean(trialspec(72, 1:50, :),3))), xlabel ('freq in Hz'), ...
    title('Average freq spectrum of the baseline, press space to continue') , pause(1)
end


% calculate the power of the ssVEP using a sliding window
[trialssVEP,winmat3d,phasestabmat,trialSNR] = freqtag_slidewin(habituationdata, 0, 1:500, 501:1500, 15, 600, 500, 'temp' );



%% conditionals for different features start here

if strcmp(featureflag, 'alphaSNR')
    % take the power spectrum for each electrode and trial and calculate the SNR for
    % the alpha power 
    for elec = 1:129
        for trial = 1:size(trialspec,3)
            trialspec(elec,:,trial) =  trialspec(elec,:,trial)./mean(trialspec(elec,[4 5 6  15 16 17],trial));
            % this uses the neighbors of alpha, 3 on each side, to get at an
            % SNR for the alpha band specifically --- replace by 1/f eventually
        end
    end
    predictor = trialspec; 
    
elseif strcmp(featureflag, 'alphapower')
    
     predictor = trialspec; 
     
elseif strcmp(featureflag, 'phase')
    
      predictor = trialphase; 
      
elseif strcmp(featureflag, 'oneoverf') % this is the power spectrum with 1/f removed
    for elec = 1:129
      for trial = 1:size(trialspec,3)
           spec = squeeze(trialspec(elec,1:40,trial)); 
           beta = polyfit(1:length(spec),spec',2);       
           expmod = abs(polyval(beta, 1:length(spec)));
           predictor(elec, :, trial) = spec./expmod;
      end
    end
    
 elseif strcmp(featureflag, 'slope') % this is the slope of the 1/f 
    for elec = 1:129
      for trial = 1:size(trialspec,3)
           spec = squeeze(trialspec(elec,1:40,trial)); 
           beta = polyfit(1:length(spec),spec',2);       
           predictor(elec, :, trial) = repmat(beta(2), 1, 40); 
      end
    end
    
  elseif strcmp(featureflag, 'offset') % this is the power spectrum with 1/f removed
    for elec = 1:129
      for trial = 1:size(trialspec,3)
           spec = squeeze(trialspec(elec,1:40,trial)); 
           beta = polyfit(1:length(spec),spec',2);       
           predictor(elec, :, trial) = repmat(beta(3), 1, 40); 
      end
    end
    
end

%% now the correlation(s) between the first set of predictors predictors and SSVEP - these are channelwise
corrmat = zeros(129,40); 
for sensor = 1:129
  for freq = 1:40
    corrmat(sensor, freq) = corr(squeeze(predictor(sensor, freq, :)), trialssVEP(sensor,:)', 'type', 'spearman'); 
  end 
end

if plotflag
 figure
  plot(squeeze(predictor(75, 11, :)), trialssVEP(75,:)', 'o'); xlabel ('predictor value'), ylabel('ssVEP power'), lsline
 title(['correlation between predictor and ssvep at Oz: ' num2str(corrmat(75,11))])
end


eval(['save ' igfilepath 'corr.mat corrmat -mat'])