
file = 'VFE_17.fl40.E1.app4'; 

[Data,Version,LHeader,ScaleBins,NChan,NPoints,NTrials,SampRate] = ...
	ReadAppData(file); 


srate = SampRate; 

time = 0:1000/SampRate:size(Data, 2).*1000/SampRate-0.004; 

%make a gentle 1 Hz highpass, in case data have not yet been highpassed. 
[fila,filb] = butter(2, 1./(srate/2), 'high');

for trial = 1:NTrials
    
    a = ReadAppData(file, trial);
    
    meanveog = ((a(8,:)-a(126,:)) + (a(25,:)-a(127,:)))./2;

     heog = a(128,:)-a(125,:);
     
     data = abs(heog +i*meanveog); 
    
    temp =  filtfilt(fila, filb, data')';
    
    ECGsquare = temp.^2;
    stdECG = std(ECGsquare);
    threshold = 2.5*stdECG;
    Rchange=  find(ECGsquare > threshold);
       Rstamps = [Rchange(find(diff(Rchange)>100)) Rchange(end)];

   
        figure (99), title(['ocular events, trial number: ' num2str(trial)])
        subplot(2,1,1), plot(time, temp), title('raw EOG')
        subplot(2,1,2),  plot(time, ECGsquare), title('integrated EOG'), hold on
        subplot(2,1,2),  plot(time(Rstamps), threshold, 'r*'), hold off
        pause

    
end


% 
% 
% for trial = 1:6; 
% 
% figure(99), clf
% 
% a = ReadAppData(file, trial);
% 
% meanveog = ((a(8,:)-a(126,:)) + (a(25,:)-a(127,:)))./2;
% 
% heog = a(128,:)-a(125,:);
% 
% plot(meanveog)
% hold on
% plot(heog)
% 
% pause
% end