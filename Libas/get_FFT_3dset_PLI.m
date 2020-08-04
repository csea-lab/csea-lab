function [spec] = get_FFT_3dset_PLI(infilemat, timewinSP, SampRate, sensors1, sensors2);
%this one reads set files, does an FT on each segment but also gets complex
%phase and averages that, then looks at phase locking between sites in
%sensors 1 and sensors 2

for fileindex = 1:size(infilemat,1)
    
    EEG = pop_loadset(deblank(infilemat(fileindex,:))); 
    
    Data3d = double(EEG.data);
    
        for trial = 1: size(Data3d,3)

        Data = squeeze(Data3d(:, timewinSP, trial));
        Data = Data .* cosinwin(20,size(Data,2), size(Data,1));  

        NFFT = size(Data,2); 
        NumUniquePts = ceil((NFFT+1)/2); 
        fftMat = fft(Data', NFFT);  % transpose: channels as columns (fft columnwise)
        Mag = abs(fftMat);                                                   % Amplitude berechnen
        Mag = Mag*2;   

        Mag(1) = Mag(1)/2;                                                    % DC trat aber nicht doppelt auf
        if ~rem(NFFT,2),                                                    % Nyquist Frequenz (falls vorhanden) auch nicht doppelt
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
        
        complexnorm = fftMat'./abs(fftMat'); 
        
        norm1 = mean(complexnorm(sensors1, :)); 
        norm2= mean(complexnorm(sensors2, :)); 
        
        diffcomplex = (norm1 - norm2)./abs(norm1 - norm2); 
         
        if trial == 1; 
            complexsum = diffcomplex; 
        else complexsum = complexsum + diffcomplex; 
        end


        end  % loop over trials

specavg = specsum ./ size(Data3d,3);

complexmean  = complexsum ./ size(Data3d,3);

PLIdiff = abs(complexmean); 


    
  %  [File,Path,FilePath]=SaveAvgFile([deblank(infilemat(fileindex,:)) '.at.spec'],specavg,[],[], fsmapnew);
  
  [File,Path,FilePath]=SaveAvgFile([deblank(infilemat(fileindex,:)) '.plidiff.at'],PLIdiff,[],[], fsmapnew);
    
    fclose('all');

	
end


	