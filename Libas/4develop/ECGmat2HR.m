function [BPMvec,HPvec]  = ECGmat2HR(ECG2d, durationinsec, plotFlag)
% ECGstruc is an eeglab structure with the ECG data, already segmented

time = 0:1/1000:length(ECG2d)/500-1/1000;

BPM = [];


data2d = ECG2d;

BPMvec = [];
HPvec = cell(size(data2d,2));

[Blow,Alow] = butter(4,.04); % first define a 6th order higpass filter at

ECG2d =filtfilt(Blow, Alow, double(data2d));

[Bhigh,Ahigh] = butter(2,.002, 'high'); % first define a 6th order higpass filter at

ECG2d =filtfilt(Bhigh, Ahigh, ECG2d);

%ECGsquare =  ((ECG2d).^2); % square the segment, to increase the signal to noise of the R wave
ECGsquare = ECG2d.^2;


for trial = 1: size(ECGsquare, 2)

    % find and plot R-peaks
    [~,Rstamps] = findpeaks(ECGsquare, 'MinPeakDistance', 400, 'MinPeakProminence',20);

    if plotFlag == 1
        figure(201)
        subplot(2,1,1), plot(ECG2d), title('raw EKG'),  xline(Rstamps)
        subplot(2,1,2),  plot(ECGsquare), title('integrated EKG'),  xline(Rstamps)
      
        title(['trial ' num2str(trial)])
        hold off
        pause
    else
    end
    Rwavestamps = time(Rstamps);
    IBIvec = diff(Rstamps);

    % calculate IBIs and BPM
    Rwavestamps = time(Rstamps);
    IBIvec = diff(Rwavestamps);
    HPvec{trial} = IBIvec;

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
end










