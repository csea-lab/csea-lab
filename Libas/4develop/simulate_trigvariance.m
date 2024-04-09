%% 1.) Initialize parameters
clear
Ntrials = 50; % sets number of simulation iterations, maybe manipulate later the SNR
%SNR = linspace(0,3,20); %sets the range of SNR 
%nSNR = length(SNR); 
%nTrials = 20; %sets number of trials per SNR value per loop - need ~20 trials for MPP training
%trialsPerSNR = nTrials*nLoops;

% 2.) Determine kernel shape make time vector
time = 0.001:0.001:1; % Five seconds of discrete time, sampled at 1000 Hz
kernel = (1./gamma(0.1:0.05:5.05)).*3; % This is a 100-element gamma function     

%% 3.) Simulate single-trial ERPS embedded in Brownian noise
%startVar = 2; % variability/jitter in ms includes
for startVar = 1:60
    for P1amplitude = 1:20
        for loop = 1:100
            for trial = 1:Ntrials
                randseed = randperm(startVar);
                jitter_trial(trial) = randseed(1)-round(startVar./2);
                start = 200+jitter_trial(trial);
                temp1 = rand(size(time))-.5; % zero-centered white noise
                brownsig = cumsum(temp1);  % Brownian noise is the cumulative sum of white noise
                %scaledSignal = signal.* SNR(x); % a 10.1Hz sine or sawtooth wave scaled by SNR
                ongoing = detrend(brownsig-mean(brownsig)); % zero-centered Brownian noise
                %plot(time, testsig2(trial,:)), pause(1) %plots each generated signal
                ongoing(start:start+99) = ongoing(start:start+99)+(kernel./P1amplitude);
                fake2dmat(trial, :) = ongoing;
            end
            ERP(loop, :) = mean(fake2dmat);
            SNR(loop) = mean(ERP(loop, 219:238)./std(ERP(loop, 400:1000)));
        end % loop
        SNRbyP1(startVar, P1amplitude) = mean(SNR(loop));
    end % P1amplitude
    fprintf('.')
end

figure(99), plot(ERP')

 

