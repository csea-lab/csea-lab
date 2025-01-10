function [spec, freqs] = get_FFT_atg(infilemat, timewinSP)

for fileindex = 1:size(infilemat,1)

    [AvgMat,File,Path,FilePath,NTrialAvgVec,StdChanTimeMat,SampRate,AvgRef,Version,MedMedRawVec,MedMedAvgVec] = ReadAvgFile(deblank(infilemat(fileindex,:)));

    %limit time series to desired interval (timewinSP) and then apply cosine
    %square window

    AvgMat = AvgMat(:,timewinSP);

    AvgMat = AvgMat .* cosinwin(10,size(AvgMat,2), size(AvgMat,1));

    NFFT = size(AvgMat,2);
    NumUniquePts = ceil((NFFT+1)/2);
    fftMat = fft(AvgMat', NFFT);  % transpose: channels as columns (fft columnwise)
    Mag = abs(fftMat);                                                   %  calculate Amplitude
    Mag = Mag*2;

    Mag(1) = Mag(1)/2;                                                    % DC trat aber nicht doppelt auf
    if ~rem(NFFT,2)                                                  % Nyquist Frequency not twice
        Mag(length(Mag))=Mag(length(Mag))/2;
    end

    Mag=Mag/NFFT; % scale FFT

    Mag = Mag';

    spec = Mag(:,1:round(NFFT./2));

    fsmapnew = 1000./(SampRate./NFFT); % this is for writing it out to emegs and use ms as Hz (ask andreas)

    [~,~,~]=SaveAvgFile([deblank(infilemat(fileindex,:)) '.spec'],spec,NTrialAvgVec,StdChanTimeMat, fsmapnew);

    sampleinterval = 1000/SampRate;
    durationseg = length(timewinSP)*sampleinterval;
    freqs = 0:1000/durationseg:SampRate/2;

end
