clear 

time = 0.001:0.001:5; % Five seconds of discrete time, sampled at 1000 Hz

nLoops = 1; 
nSNR = 10;
nTrials = 10; 
SNR = linspace(0.1,1,30); %sets the range of SNR from .1 to nSNR/10 in steps of .1
nSNR = length(SNR); 


sawFlag = 0; 
if sawFlag == 0
    signal = sin(2*pi*time(1:400)*10);
elseif sawFlag == 1
    signal = sawtooth(2*pi*time(1:400)*10);
end

[a, b] = butter(5, 0.028);
[ahigh, bhigh] = butter(5, 0.008, 'high');

%% 3.) Calculate frequency resolution of data for wavelet analysis

fr = 1/5;
nyq = 500;
faxistotal = 0:fr:nyq;
faxis = faxistotal(36:5:66);

for loop = 1:nLoops

    for x = 1:nSNR % SNRs

        testsig2 = zeros(nTrials,5000);
        for trial = 1:nTrials
            
            whitesig = randn(size(time));
            %temp1 = rand(size(time))-.5; % zero-centered white nois
            %brownsig = cumsum(temp1);  % Brownian noise is the cumulative sum of white noise
            scaledSignal = signal.* SNR(x); % a 10Hz sine or sawtooth wave scaled by SNR
            testsig2(trial,:)  = detrend(whitesig-mean(whitesig)); % zero-centered Brownian noise
            SNRtrue(trial, x) = SNR(x)./range(testsig2(trial, :));
            testsig2(trial, 3001:3400) =  testsig2(trial, 3001:3400) + scaledSignal; % add the sine wave to part of the Brownian noise
  
        end
        
        testsigs(x,loop,:,:) = testsig2; %4D matrix containing unfiltered generated signals: SNR x loop x trial x time
    end
end

data_tmp = squeeze(testsigs);

data = permute(data_tmp, [1 3 2]); 

[WaPower4d] = wavelet_app_mat_singtrials(data, 1000, 51, 51, 1); 

% loop ? 

WaPower3d = squeeze(WaPower4d); 

db_tr = []; 
% this loop is for sensitivity
for snr_index = 1:size(WaPower3d, 1)

    for trial_index = 1:size(WaPower3d, 3)

        tr_pow = squeeze(WaPower3d(snr_index,:, trial_index));

       bslAvg = mean(tr_pow(1:1000)); 
     
       db_tr(snr_index, trial_index, :) = 10.*log10(tr_pow./bslAvg); %scales each column of f_all by bslAvg

    end



end




