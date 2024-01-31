
clear 

     [a, b] = butter(5, 0.028);
     [ahigh, bhigh] = butter(5, 0.008, 'high');

     time = 0.001:0.001:5; % Five seconds of discrete time, sampled at 1000 Hz

%MPPsims contains 10 loops, each loop is 20 SNRs x 20 trials
%each column contains trials for an SNR
MPPsims = cell(10,1);
testsigs = NaN(30,10,20,5000);
tic
for loop = 1:10

    for x = 1:30 % SNRs
        
        for trial = 1:20

            temp1 = rand(size(time))-.5; % zero-centered white nois
            brownsig = cumsum(temp1);  % Brownian noise is the cumulative sum of white noise
            SinWave = sin(2*pi*time(1:1000)*10.1).* x./10; % a sine wave
            testsig2(trial,:)  = detrend(brownsig-mean(brownsig)); % zero-centered Brownian noise
            SNR(trial, x) = x./range(testsig2(trial, :));
            testsig2(trial, 3001:4000) =  testsig2(trial, 3001:4000) + SinWave; % add the sine wave
            %plot(time, testsig2(trial,:)), pause(1)
  
        end
        
        testsigs(x,loop,:,:) = testsig2; %SNR x loop x trial x time

        testigfilt = filtfilt(a,b, testsig2')';
        testigfilt = filtfilt(ahigh,bhigh, testigfilt')';

        [D, MPP(:, x), th_opt] = PhEv_Learn_fast_2(testigfilt, 200, 3);

    fprintf(['loop ' num2str(loop) ' SNR ' num2str(x) '\n'])
    
    end 

    MPPsims(loop) = {MPP};

end
toc
save('MPPsimsSin_.03dBto3dB.mat','MPPsims')
save('MPPsimsSin_signals.03dBto3dB.mat','testsigs')
%% Unpack MPPsims, reorganize
MPPsims2 = cell(10,50);
MPPsnr = cell(200,1);

for x = 1:50
    for loop = 1:10
        MPPsims2(loop,x) = {MPPsims{loop,1}(:,x)};
    end
end

    %%

taus = cell(200,50);
taus_loops = cell(10,20,50);
idx = 0:20:180;
takeRast = true;
for x = 1:50
    for loop = 1:10
        for y = 1:20
            if ~isempty(MPPsims2{loop,x}(y).Trials)
                t = 1;
                taus_tr = [];
                while takeRast == true
                    try 
                       taus_tr(t) = MPPsims2{loop,x}(y).Trials(t).tau;
                       t = t+1;
                    catch
                        taus(y+idx(loop),x) = {taus_tr};
                        taus_loops(loop,y,x) = {taus_tr};
                        break
                    end
                end     
            end
        end
    end
end


    %%

taus_all = cell(30,10);
for s = 1:30
    for l = 1:10
        rg = 0:20:180;
        tau_loop = [];
        for i = (1+rg(l)):(20+rg(l))
            taus_tr = taus{i,s};
            tau_loop = [tau_loop, taus_tr];
        end
        taus_all(s,l) = {tau_loop};
    end
end

outmat = zeros(30,10);

for x = 1:30
    for loop = 1:10
    outmat(x,loop) = length(find(taus_all{x,loop}-3000 >= 0 & taus_all{x,loop}-3000 <= 1000));
    end
end

outmat = zeros(30,1);

for x = 1:30
    for tr = 1:20
    outmat(x) = outmat(x) + length(find(taus{tr,x}-3000 >= 0 & taus{tr,x}-3000 <= 1000));
    end
end

outmat_loops = zeros(30,20,10);
for x = 1:30
    for tr = 1:20
        for l = 1:10
            outmat_loops(x,tr,l) = outmat_loops(x,tr,l) + length(find(taus_loops{l,tr,x}-3000 >= 0 & taus_loops{l,tr,x}-3000 <= 1000));
        end
    end
end


%%
SNR = .1:.1:3;

figure, 
for l = 1:10
    plot(outmat(:,l))
    hold on
end

avgOutmat = mean(outmat,2);
plot(avgOutmat,'m','lineWidth',4)

seOutmat = std(outmat,0,2)/sqrt(10);
sdOutmat = std(outmat,0,2);
rgOutmat = range(outmat,2)./2;

figure, shadedErrorBar([],avgOutmat,sdOutmat,'lineprops',{'m','markerfacecolor','magenta','lineWidth',2})
xlim([0 30]), xticks(1:30), xticklabels(SNR)
xlabel('Signal-to-Noise Ratio (dB)')
ylabel('Detected 10.1Hz Oscillatory Events')


    %plot((100.*mean(outmat')./60)), xticks(mean(SNR)), xticklabels(mean(SNR))





%% Do the same thing for sawtooth

%time = 0.001:0.001:5; % Five seconds of discrete time, sampled at 1000 Hz
%[asaw, bsaw] = butter(5, 0.045);

%temp = sawtooth(2*pi*time(1:1000)*10.1).* 5./10; % a sawtooth wave
%SawWave = filtfilt(asaw,bsaw, temp')';

clear 
     [asaw, bsaw] = butter(5, 0.045);
     [a, b] = butter(5, 0.028);
     [ahigh, bhigh] = butter(5, 0.008, 'high');

     time = 0.001:0.001:5; % Five seconds of discrete time, sampled at 1000 Hz

%MPPsims contains 10 loops, each loop is 20 SNRs x 20 trials
%each column contains trials for an SNR
MPPsims = cell(10,1);
testsigs = NaN(50,10,20,5000);
tic
for loop = 1:10

    for x = 1:50 % SNRs
       
        for trial = 1:20

            temp1 = rand(size(time))-.5; % zero-centered white nois
            brownsig = cumsum(temp1);  % Brownian noise is the cumulative sum of white noise
            temp = sawtooth(2*pi*time(1:1000)*10.1).* x./10; % a sawtooth wave
            SawWave = filtfilt(asaw,bsaw, temp')';
            testsig2(trial,:)  = detrend(brownsig-mean(brownsig)); % zero-centered Brownian noise
            SNR(trial, x) = x./range(testsig2(trial, :));
            testsig2(trial, 3001:4000) =  testsig2(trial, 3001:4000) + SawWave; % add the sine wave
            %plot(time, testsig2(trial,:)), pause(1)
  
        end
        
        testsigs(x,loop,:,:) = testsig2; 

        testigfilt = filtfilt(a,b, testsig2')';
        testigfilt = filtfilt(ahigh,bhigh, testigfilt')';

        [D, MPP(:, x), th_opt] = PhEv_Learn_fast_2(testigfilt, 200, 4);

    fprintf(['loop ' num2str(loop) ' SNR ' num2str(x) '\n'])
    
    end 

    MPPsims(loop) = {MPP};

end
toc
save('MPPsimsSaw_.1dBto5dB.mat','MPPsims')
save('MPPsimsSaw_signals.1dBto5dB.mat','testsigs')

%% Do with FFT and SAW

     load('MPPsimsSaw_signals.1dBto5dB.mat')

     clear outmat; 

     time = 0.001:0.001:5; % Five seconds of discrete time, sampled at 1000 Hz

%MPPsims contains 10 loops, each loop is 20 SNRs x 20 trials
%each column contains trials for an SNR
% MPPsims = cell(10,1);
% testsigs = NaN(50,10,20,5000);
tic
for loop = 1:10

    for x = 1:30 % SNRs
       
        for trial = 1:20

        tempsig = squeeze(testsigs(x, loop, trial, :)); 

        [WaPower, PLI, PLIdiff] = wavelet_app_mat(tempsig', 1000, 46, 63, 1, []);
        
        outmatMorl(x, loop, trial) = mean(squeeze(WaPower(1, 3000:4000, 6))) - mean(squeeze(WaPower(1, 2600:3000, 6)));

        end
        
   % fprintf(['loop ' num2str(loop) ' SNR ' num2str(x) '\n'])
    
    end 

   % MPPsims(loop) = {MPP};
end

