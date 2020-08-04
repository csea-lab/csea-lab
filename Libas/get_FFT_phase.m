function [complexphase] = get_FFT_phase(filemat, timewinSP, sensor);


for fileindex = 1:size(infilemat,1)
    
    [AvgMat,File,Path,FilePath,NTrialAvgVec,StdChanTimeMat,...
	SampRate,AvgRef,Version,MedMedRawVec,MedMedAvgVec] = ReadAvgFile(infilemat(fileindex,:));


    
%limit time series to desired interval (timewinSP) and then apply cosine
%square window
  
    AvgMat = AvgMat(:,timewinSP); 
   % AvgMat = [AvgMat zeros(257,250)]; %%%%% !!!!!!!!!!!!!!!!!!!!!!!@@@@ AAAAAARGH
   
    
       AvgMat = AvgMat .* cosinwin(20,size(AvgMat,2), size(AvgMat,1));  
  
    NFFT = size(AvgMat,2); 
	NumUniquePts = ceil((NFFT+1)/2); 
	fftMat = fft(AvgMat', NFFT);  % transpose: channels as columns (fft columnwise)

    normcompmat = fftMat./abs(fftMat); 
    
    complexphase(fileindex) = (normcompmat(sensor)); 
	
end
	