
clear 

for loop = 1:10
time = 0.001:0.001:5; % Five seconds of discrete time, sampled at 1000 Hz

[a, b] = butter(5, 0.028);

    for x = 1:20 
    
        for trial = 1:60
    
            temp1 = rand(size(time))-.5; % zero-centered white nois
            brownsig = cumsum(temp1);  % Brownian noise is the cumulative sum of white noise
            SinWave = sin(2*pi*time(1:1000)*(10.1 + x/100)).* x; % a sine wave
            testsig2(trial,:)  = detrend(brownsig-mean(brownsig)); % zero-centered Brownian noise
            SNR(trial, x) = x./range(testsig2(trial, :));
            testsig2(trial, 3001:4000) =  testsig2(3001:4000) + SinWave; % add the sine wave
           
        end
    
        testigfilt = filtfilt(a,b, testsig2')';
    
        [D, MPP(:, x), th_opt] = PhEv_Learn_fast_2(testigfilt, 200, 4);
    
    
    end

end
    %%
    for x = 1:60,
        for y = 1:20,
            if ~isempty(MPP(x,y).Trials)
                aha(x,y) = MPP(x,y).Trials(1).tau; 
            end
        end
    end

    %%
    for x = 1:20
        outmat(x, loop) = length(find(abs(aha(:, x)-3500) < 400));
    end


%%
plot((100.*mean(outmat')./60)), xticks(1:20), xticklabels(mean(SNR))
