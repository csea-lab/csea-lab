function [SpecSNR, expmodmat] = getsnrspecMAT(filemat, freqband, signalfreq)

% Divide FFT spectrum by a fitted model of the spectrum to eliminate 1/f noise floor.
% Function assumes a file matrix with spectra in .atg format, with rows of sensors and
% columns of frequencies as "timepoints."

% filemat: of spec files
% freqband: must cover the range of sample points of the passband of each spectrum.
    % most often high- and lowpass filter cutoffs from prepro, [#:#]
% signalfreq: target/driving frequencies [# #] tehy will be excluded from
% the fitting, to avoid fitting the signal as noise
     
% e.g. getsnrspecMAT(filemat,[1:40],[8.57 12]);

% ============================================================== HR, July 2019


for fileindex = 1:size(filemat,1)
   
    %Extract the file name.
    specpath = deblank(filemat(fileindex,:));

    %Read in each spectrum.
    temp = load(specpath);
   
    freqs = temp.freqs; 
    phase = temp.phase; 
    AvgMat = temp.pow; 
    
     % sometimes a good idea not to include signal below and above your
    % filter cutoff :-) 
    takebinsmin = max(find(freqs<freqband(1)));
    takebinsmax = min(find(freqs>freqband(end)));
    
    freqs = freqs(takebinsmin:takebinsmax); 
    phase = phase(:,takebinsmin:takebinsmax); 
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
    
    chan4plot = 16
    figure(11)
    subplot(2,1,1), plot(freqs, AvgMat(chan4plot,:)), hold on, plot(freqs, expmodmat(chan4plot,:)), title(['data and fit, channel ' num2str(chan4plot)])
    subplot(2,1,2),plot(freqs, SpecSNR(chan4plot,:)), title('SNR')
    hold off
   
end

% close all

end