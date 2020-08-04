function [spec_envelope] = get_FFT_envelope(folder, noftimpoints)
% user needs to know sample rates, and how to convert bins to Hz and msec,
% this is not a cozy program that does
% everything for you :-) ... grow up!!!!

infilemat = dir([folder '/*.at*']); 

for fileindex = 1:size(infilemat,1)
    
    [Datamat,File,Path,FilePath,NTrialAvgVec,StdChanTimeMat,...
	SampRate,AvgRef,Version,MedMedRawVec,MedMedAvgVec] = ReadAvgFile(infilemat(fileindex).name);
   
    % limit to the nofpoints then apply cosine square window, do FFT, shift FFT
    % window, do it all over again. 
   
    % shift window
    for timewinstart = 1:size(Datamat,2)-noftimpoints
        
        if timewinstart/10 == round(timewinstart/10), fprintf('.'), end
         if timewinstart/100 == round(timewinstart/100), disp(timewinstart), end
        
        
        AvgMat = Datamat(:, timewinstart:timewinstart+noftimpoints);  
        
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
    
        spec_envelope(:,timewinstart, :) = Mag(:,1:round(NFFT./2)); 
          
    
    end
    
      eval(['save ' infilemat(fileindex).name '.env.mat spec_envelope -mat']); 
	
end
	