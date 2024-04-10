function [BPMvec]  = eeglab2HR_gaborgen(ECGstruc, durationinsec) 
% ECGstruc is an eeglab structure with the ECG data, already segmented
if nargin < 3, threshfac = []; end

time = 0:1/ECGstruc.srate:durationinsec;

BPM = []; 
BPMvec = []; 

data2d = squeeze(ECGstruc.data); % ECG time by trial

[Blow,Alow] = butter(4,.02); % first define a 6th order higpass filter at

ECG2d =filtfilt(Blow, Alow, double(data2d)); % filter the ecg data high

%[Bhigh,Ahigh] = butter(6,.005, 'high'); % first define a 6th order higpass filter at

% ECG2d =filtfilt(Bhigh, Ahigh, ECG2d); % filter the ecg data high
    
ECGsquare =  ((ECG2d).^2); % square the segment, to increase the signal to noise of the R wave
     
%    subplot(2,1,1), plot(time, ECG), title('raw EKG')
% 
%    subplot(2,1,2),  plot(time, ECGsquare), title('integrated EKG'), hold on

   for trial = 1: size(ECGsquare, 2)

    figure(101)
    % find and plot R-peaks
    stdECG = std(ECGsquare(:, trial)); 
    threshold = 2.25*stdECG; 
    Rchange=  find(ECGsquare(:, trial) > threshold);
    Rstamps = [Rchange(find(diff(Rchange)>100)); Rchange(end)];
    Rstamps = [Rstamps(find(diff(Rstamps)>300)); Rstamps(end)];
    plot(ECGsquare(:, trial)), hold on
    plot(Rstamps, threshold, 'r*') 
    hold off 
    pause
    Rwavestamps = time(Rstamps);
    IBIvec = diff(Rstamps);

   % calculate IBIs and BPM
   Rwavestamps = time(Rstamps);
   IBIvec = diff(Rwavestamps);

   [BPMvec(:,trial)]  = IBI2HRchange_halfsec(IBIvec, durationinsec); 

   end
    
   BPMvec_clean = BPMvec; 

   for trial = 1:size(BPMvec,2)

   index2 = find(abs(diff(BPMvec(:, trial)))>10);
       if ~isempty(index2)
         index2 = [index2; index2(end)+1];
         BPMvec_clean(index2,trial) = mean(BPMvec(:,trial));
       end

   end
   

         


    
   



