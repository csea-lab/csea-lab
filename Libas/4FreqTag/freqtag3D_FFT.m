function [meanpower] = freqtag3D_FFT(dataset, timewinSP, fsamp);

% This function applies the Fast Fourier Transform on a 3-D data,
% where M are sensors and N time points. timewin is the epoch size. fsamp is the sampling rate in Hz.


for trial = 1: size(dataset,3)       % Start of the trial loop

        Data = squeeze(dataset(:, timewinSP, trial));
        
        NFFT = size(Data,2);               % Extract the number of data points in the dataset
        fftMat = fft(Data', NFFT);         % Here, the data becomes time points by sensors using the transpose to feed the fft function
        Mag = abs(fftMat);                 % Calculate the amplitude                                        
        Mag = Mag*2;   

        Mag(1) = Mag(1)/2; 
        
            if ~rem(NFFT,2),                                                   
            Mag(length(Mag))=Mag(length(Mag))/2;
            end

        Mag=Mag/NFFT;                      % After computing the fft, the coefficients will be scaled in terms of frequency (in Hz)

        Mag = Mag';                        % Sensors as rowls again

        meanpower = Mag(:,1:round(NFFT./2));    % Scaling the power

    

             if     trial == 1; 
                    specsum = meanpower; 
             else   specsum = specsum + meanpower; 
             end


end                                         % End of the trial loop

   meanpower = specsum ./ size(dataset,3);       % Scaling the spectrum by the number of trials
    
  
    
    	
