function [specavg, freqs] = FFT_spectrum3D(Data3d, timewinSP, SampRate);
   
fRes = 1000./(size(Data3d, 2).*(1000/SampRate));
freqs = 0:fRes:SampRate./2; 

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

        if trial == 1; 
            specsum = spec; 
        else specsum = specsum + spec; 
        end

        end  % loop over trials

    specavg = specsum ./ size(Data3d,3);
 	
end % loop over trial


	