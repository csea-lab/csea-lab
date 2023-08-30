function [BPM_mat]  = app2HR2023(filemat) 

% first define useful stuff: 
[B,A] = butter(6,.05, 'high'); 

% secbins are the 1 second segments that are being considereed
secbins = 0:10;

for fileindex = 1:size(filemat,1); 
   
    BPM_mat = [];

% read  file and chekc how many trials 

[dummy,Version,LHeader,ScaleBins,NChan,NPoints,NTrials,SampRate,AvgRefStatus,File,Path,FilePath,EegMegStatus,NChanExtra,AppFileFormatVal]=...
	ReadAppData(deblank(filemat(fileindex,:)));

time = 0:1000/SampRate:size(dummy,2).*1000/SampRate-1000/SampRate; 

figure

for trial = 1: NTrials 
    % read, calculate and plot   
    [a]=ReadAppData(deblank(filemat(fileindex,:)), trial);
    % ECG =filtfilt(B, A, a(121,:) - a(228,:)); 
    ECG =filtfilt(B, A, a(73,:) - a(121,:)); 
    ECGsquare = ((ECG.^2)) 
    
    figure(1)
    
    subplot(2,1,1)
    plot(time, ECG), title('raw')
    subplot(2,1,2)
    plot(time, ECGsquare), title('square')   
    hold on
    
    % find and plot R-peaks
    stdECG = std(ECGsquare); 
    threshold = 4*stdECG; 
    Rchange=  find(ECGsquare > threshold);
    Rstamps = [Rchange(find(diff(Rchange)>10)) Rchange(end)];
    subplot(2,1,2)
    plot(time(Rstamps), 1000, 'r*')
    hold off
 
    
    pause(1)

      % convert to IBIs
    Rwavestamps = time(Rstamps)./1000; 
    IBIvec = diff(Rwavestamps);
                

    % artifact handling

    index1 = find(abs(IBIvec) > .5) + 1;
    HRchange20sec(index1) = mean(HRchange20sec); 
    HRchange20sec(HRchange20sec<.5) = HRchange20sec(HRchange20sec<.5).*2; 
    HRchange20sec(HRchange20sec<.5) = HRchange20sec(HRchange20sec<.5).*2;
    HRchange20sec(HRchange20sec<.5) = HRchange20sec(HRchange20sec<.5).*2;
    HRchange20sec(HRchange20sec>2) = log(HRchange20sec(HRchange20sec>2));
                

       
  

   
   
end %trial

fclose('all'); 
end % fileindex


