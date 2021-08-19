function [pow, phase, freqs] = freqtag_FFT(dataset, fsamp);

% This function applies the Fast Fourier Transform on a 2-D (M-by-N) data,
% where M are sensors and N time points. fsamp is the sampling rate in Hz.

    NFFT = size(dataset,2);        % Extract the number of data points in the dataset
	fftMat = fft(dataset', NFFT);  % Here, the data becomes time points by sensors using the transpose to feed the fft function
	phase = angle(fftMat);      % Calculate the phase
    Mag = abs(fftMat);          % Calculate the amplitude
	Mag = Mag*2;                
	
	Mag(1) = Mag(1)/2;                                                  % DC Frequency not twice
	if ~rem(NFFT,2),                                                    % Nyquist Frequency not twice
        Mag(length(Mag))=Mag(length(Mag))/2;
	end
	
	Mag=Mag/NFFT;               % After computing the fft, the coefficients will be 
                                % scaled in terms of frequency (in Hz) 
    
    Mag = Mag';                 % Sensors as rowls again
    phase = phase';
    
    pow = Mag(:,1:round(NFFT./2));              % Scaling the power
    phase  = phase(:,1:round(NFFT./2));         % Scaling the phase
    select = 1:(NFFT+1)/2;                      % Scaling the frequencies
    freqs = (select - 1)'*fsamp/NFFT;
    
    