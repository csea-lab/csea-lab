function [HRmat] = getHRfromICA(filemat, plotflag)
%

srate = 500; 

for fileindex = 1:size(filemat,1)
    name = filemat(fileindex,1:19);
    cond = filemat(fileindex,20);
    HRmat = []; 

    data = ReadAvgFile(deblank(filemat(fileindex,:))); 
   
    for trial = 1:size(data,1); 
        temp = data(trial,:);
        
        temp = [diff(temp) 0]; 
        
        ECGsquare = temp.^2;
        stdECG = std(ECGsquare);
        
        threshold = 2*stdECG;
              
        time = 0:1000/srate:length(temp).*1000/srate-1000/srate;      
        
        Rchange=  find(ECGsquare > threshold);
        Rstamps = [Rchange(find(diff(Rchange)>125)) Rchange(end)];

        if plotflag 
            figure (99), title(['heart rate and R peaks, trial number: ']) % num2str(trial)])
            subplot(3,1,1), plot(time, temp), title(['raw EKG Trial ' num2str(trial)])
            subplot(3,1,2),  plot(time, ECGsquare), title('integrated EKG'), hold on
            subplot(3,1,2),  plot(time(Rstamps), threshold, 'r*'), hold off
            pause
        end

        Rstampsclean = (time(Rstamps))./1000;
        HRmat(trial,:) = IBI2HRchange_halfsec(Rstampsclean, 6);
        if plotflag
            subplot(3,1,3),  plot(HRmat')
        end

    end

    SaveAvgFile([name '.' cond '.HR_halfsec'], HRmat); 

end % loop pver files