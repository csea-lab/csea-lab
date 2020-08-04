function [HRmat] = getRstampsfromeeglab(setfilepath, plotflag)
%wants a set file with ECG data, already segmented, and with only one
%channel, which is ECG ...It will on a good day, for clean ECG  output the
%HR in 12 1-second bins (relative to epoch start), using IBI2HRchange_core.m
% if it does not, akeil@ufl.edu
% this version assumes epoch from -3 seconds, for at least 7 secs after
% !!!! better would be -3 to 9 second epochs

HRmat = []; 

a = pop_loadset(setfilepath); 

data = a.data; 
time = a.times; 
srate = a.srate;

%make a gentle 1 Hz highpass, in case data have not yet been highpassed. 
[fila,filb] = butter(2, 1./(srate/2), 'high');

for trial = 1:size(data,3)
    temp = double(squeeze(data(:, :, trial)));
    temp =  filtfilt(fila, filb, temp')';
    ECGsquare = temp.^2;
    stdECG = std(ECGsquare);
    threshold = 2.5*stdECG;
    Rchange=  find(ECGsquare > threshold);
    Rstamps = [Rchange(find(diff(Rchange)>10)) Rchange(end)];

    if plotflag 
        figure (99), title(['heart rate and R peaks, trial number: ' num2str(trial)])
        subplot(2,1,1), plot(time, temp), title('raw EKG')
        subplot(2,1,2),  plot(time, ECGsquare), title('integrated EKG'), hold on
        subplot(2,1,2),  plot(time(Rstamps), threshold, 'r*'), hold off
        pause
    end
    
    Rstampsclean = (time(Rstamps)+3000)./1000;
    HRmat(trial,:) = IBI2HRchange_core(Rstampsclean, 12);
    
end



