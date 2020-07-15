function [spec] = get_FFT_app(infilemat, timewinSP, extension);

for fileindex = 1:size(infilemat,1)
    
    [Data,Version,LHeader,ScaleBins,NChan,NPoints,NTrials,SampRate,AvgRefStatus,...
        File,Path,FilePath,EegMegStatus,NChanExtra,AppFileFormatVal]=...
	ReadAppData(deblank(infilemat(fileindex,:)));

 

for trial = 1: NTrials
    
    [Data,Version,LHeader,ScaleBins,NChan,NPoints,NTrials,SampRate,AvgRefStatus,...
        File,Path,FilePath,EegMegStatus,NChanExtra,AppFileFormatVal]=...
	ReadAppData(deblank(infilemat(fileindex,:)), trial);

    Data = Data(:, timewinSP); 

    Data = Data .* cosinwin(20,size(Data,2), size(Data,1));  
      
    NFFT = size(Data,2); 
	NumUniquePts = ceil((NFFT+1)/2); 
	fftMat = fft(Data', NFFT);  % transpose: channels as columns (fft columnwise)
	Mag = abs(fftMat);                                                   % Amplitude calculation
	Mag = Mag*2;   
	
	Mag(1) = Mag(1)/2;                                                    % DC frequency is not in there twice
	if ~rem(NFFT,2),                                                    % Nyquist Frequenz is only in there 
        Mag(length(Mag))=Mag(length(Mag))/2;
	end
	
	Mag=Mag/NFFT; % FFT so skalieren, da? sie keine Funktion von NFFT ist
    
    Mag = Mag'; 
    
    spec = Mag(:,1:round(NFFT./2)); 
    
    fsmapnew = 1000./(SampRate./NFFT);

    if trial == 1; 
        specsum = spec; 
    else specsum = specsum + spec; 
    end
    
    
end  % loop over trials

specavg = specsum ./ NTrials;
    
    [File,Path,FilePath]=SaveAvgFile([deblank(infilemat(fileindex,:)) '.' extension '.at.spec'],specavg,[],[], fsmapnew);
    
    fclose('all');

	
end


	