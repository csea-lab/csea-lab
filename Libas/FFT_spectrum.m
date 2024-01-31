function [pow, phase, freqs] = FFT_spectrum(data, fsamp)
% takes "data", which can be a vector or a matrix (in which time points are columns and sensors
% are rows) and calculates a normalized spectrum using a cosine window with
% 20 sample points rise time at the beginning and end, based on matlab FFT
% algorithm 
% lengthinmsec = size(data,2)*1000/fsamp ; 
%freqs = 0:1000/lengthinmsec:fsamp/2 ; 

    AvgMat = data; 
    
    % AvgMat = AvgMat .* cosinwin(20,size(AvgMat,2), size(AvgMat,1));  % window data
  
    NFFT = size(AvgMat,2); 
	NumUniquePts = ceil((NFFT+1)/2); 
	fftMat = fft(AvgMat', NFFT);  % transpose: channels as columns (fft columnwise)
	phase = angle(fftMat); 
    Mag = abs(fftMat);                                                   %  calculate Amplitude
	Mag = Mag*2;   
	
	Mag(1) = Mag(1)/2;                                                    % DC Frequency not twice
	if ~rem(NFFT,2)                                                    % Nyquist Frequency not twice
        Mag(length(Mag))=Mag(length(Mag))/2;
	end
	
	Mag=Mag/NFFT; % scale FFT 
    
    Mag = Mag'; 
    phase = phase';
    
    pow = Mag(:,1:round(NFFT./2)); 
    phase  = phase(:,1:round(NFFT./2)); 
    select = 1:(NFFT+1)/2;
    freqs = (select - 1)'*fsamp/NFFT;