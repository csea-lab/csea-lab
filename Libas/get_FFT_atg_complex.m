function [spec] = get_FFT_atg_complex(folder, timewinSP)

infilemat = dir([folder '/*.at*']); 

for fileindex = 1:size(infilemat,1)
    
    [AvgMat,File,Path,FilePath,NTrialAvgVec,StdChanTimeMat,...
	SampRate,AvgRef,Version,MedMedRawVec,MedMedAvgVec] = ReadAvgFile(infilemat(fileindex).name);
   
%limit time series to desired interval (timewinSP) and then apply cosine
%square window
  
    AvgMat = AvgMat(:,timewinSP); 
   
     AvgMat = AvgMat .* cosinwin(20,size(AvgMat,2), size(AvgMat,1));  
  
    NFFT = size(AvgMat,2); 
	NumUniquePts = ceil((NFFT+1)/2); 
	fftMat = fft(AvgMat', NFFT);  % transpose: channels as columns (fft columnwise)
	Mag = abs(fftMat);                                                   %  calculate Amplitude
	Mag = Mag*2;   
	
	Mag(1) = Mag(1)/2;                                                    % DC trat aber nicht doppelt auf
	if ~rem(NFFT,2),                                                    % Nyquist Frequency not twice
        Mag(length(Mag))=Mag(length(Mag))/2;
	end
	
	Mag=Mag/NFFT; % scale FFT 
    
    Mag = Mag'; 
    
    spec = Mag(:,1:round(NFFT./2)); 
    
    fftMat = fftMat'; 
    fftMat = fftMat(:,1:round(NFFT./2)); 
    
    
    fsmapnew = 1000./(SampRate./NFFT);
    
    [File,Path,FilePath]=SaveAvgFile([infilemat(fileindex).name '.imagspec'],imag(fftMat),NTrialAvgVec,StdChanTimeMat, fsmapnew);
    [File,Path,FilePath]=SaveAvgFile([infilemat(fileindex).name '.realspec'],real(fftMat),NTrialAvgVec,StdChanTimeMat, fsmapnew);
	
end
	