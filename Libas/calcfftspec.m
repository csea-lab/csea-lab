function [ampspec, freqvec] = calcfftspec(filemat, fsamp)

for index = 1:size(filemat,1); 

    winmat = readavgfile([filemat(index).name]); 
    
    winmat = winmat';
    
    NFFT = size(winmat,1); 
	NumUniquePts = ceil((NFFT+1)/2); 
	fftMat = fft (winmat);  % make sure matrix is transposed: channels as columns (fft columnwise)
	Mag = abs(fftMat);      % Amplitude berechnen
	Mag = Mag*2;   
	
	Mag(1) = Mag(1)/2;                                                    % DC trat aber nicht doppelt auf
	if ~rem(NFFT,2),                                                    % Nyquist Frequenz (falls vorhanden) auch nicht doppelt
        Mag(length(Mag))=Mag(length(Mag))/2;
	end
	
	ampspec=Mag/NFFT;   % FFT so skalieren, da? sie keine Funktion von NFFT ist
	freqvec = (0:NumUniquePts-1) .* 1000./(1000/fsamp*NFFT); 
    
end

	

    
    
 