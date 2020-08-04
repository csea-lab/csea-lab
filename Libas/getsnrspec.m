function [SpecSNR, expmodmat, freqs] = getsnrspec(filemat, freqband, signalfreq, nyquist)

% Divide FFT spectrum by a fitted model of the spectrum to eliminate 1/f noise floor.
% Function assumes a file matrix with spectra in .atg format, with rows of sensors and
% columns of frequencies as "timepoints."
% nyquist os half the original time domain sample rate of the EG system, so
% for exampe 250 if sampled at 500 Hz
% can plot result as plot(freqs, SpecSNR') to check if it works for your data
% typical call:  [SpecSNR, expmodmat, freqs] = getsnrspec('flicknathaly_101.fl21h4.E1.csd.at2.ar.spec', 4:21, 10, 250);


for fileindex = 1:size(filemat,1)
   
    %Extract the file name.
    specpath = deblank(filemat(fileindex,:));

    %Read in each spectrum.
   [AvgMat,File,Path,FilePath,NTrialAvgVec,StdChanTimeMat,...
	SampRate] = ReadAvgFile(specpath);
   
    freqs = 0: 1000/SampRate : nyquist-(1000/SampRate); 
    
    % sometimes a good idea not to include signal below and above your
    % filter cutoff :-) 
    takebinsmin = max(find(freqs<freqband(1)));
    takebinsmax = min(find(freqs>freqband(end)));
    
    freqs = freqs(takebinsmin:takebinsmax); 
    AvgMat = AvgMat(:,takebinsmin:takebinsmax);
    
    
    %Set spectrum parameters.
    f0 = freqs(2)-freqs(1); %Frequency resolution.
    faxis = freqs; %Vector of frequencies in Hz.
    allbins = 1:size(AvgMat,2); 
    signalbins = find(ismember(faxis, signalfreq));
    noisebins = find(~ismember(faxis, signalfreq));
   
    % throw away the signal bins before fitting
    spec4fit = AvgMat; 
    spec4fit(:, signalbins) = []; 
 
    % Find the model that best fits the spectrum noisebins at each sensor.
    % then apply to data
   
    for sensorindex = 1:size(AvgMat,1)
        
        sensorspec1 = spec4fit(sensorindex,:);
        
        [beta] = polyfit(noisebins,sensorspec1,2);
       
        [expmod] = abs(polyval(beta, allbins));
        
        expmodmat(sensorindex,:) = expmod;
        
        SpecSNR(sensorindex,:) = AvgMat(sensorindex,:)./expmod; %Divide spectrum by the model.
    end
    
    
end

