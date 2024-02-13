%% 1.) Initialize important parameters
nLoops = 3; %sets number of training iterations for each SNR value
SNR = linspace(0,.9,10); %sets the range of SNR from .1 to nSNR/10 in steps of .1
nSNR = length(SNR); 
nTrials = 10; %sets number of trials per SNR value per loop - need ~20 trials for MPP training
trialsPerSNR = nTrials*nLoops;
sawFlag = 0; %determines shape of signal; if 0, generates sine wave; if 1, generates sawtooth wave

%MPP hyperparameters
M = 300; %length of detection window
K = 3; %number of dictionaries

%% 2.) Determine signal shape, create filters for MPP processing

time = 0.001:0.001:5; % Five seconds of discrete time, sampled at 1000 Hz

if sawFlag == 0
    signal = sin(2*pi*time(1:1000)*10.1);
elseif sawFlag == 1
    signal = sawtooth(2*pi*time(1:1000)*10.1);
end

[a, b] = butter(5, 0.028);
[ahigh, bhigh] = butter(5, 0.008, 'high');

     

%% 3.) Simulate sine waves embedded in Brownian noise varying in SNR and estimate MPPs
%MPPsims contains nLoop loops, each loop is nSNR x nTrials
%each column contains trials for an SNR
MPPsims = cell(nLoops,1);
testsigs = NaN(nSNR,nLoops,nTrials,5000);

for loop = 1:nLoops

    for x = 1:nSNR % SNRs
        
        for trial = 1:nTrials

            temp1 = rand(size(time))-.5; % zero-centered white nois
            brownsig = cumsum(temp1);  % Brownian noise is the cumulative sum of white noise
            scaledSignal = signal.* SNR(x); % a 10.1Hz sine or sawtooth wave scaled by SNR
            testsig2(trial,:)  = detrend(brownsig-mean(brownsig)); % zero-centered Brownian noise
            SNRempirical(trial, x) = x./range(testsig2(trial, :));
            testsig2(trial, 3001:4000) =  testsig2(trial, 3001:4000) + scaledSignal; % add the sine wave to part of the Brownian noise
            %plot(time, testsig2(trial,:)), pause(1) %plots each generated signal
  
        end
        
        testsigs(x,loop,:,:) = testsig2; %4D matrix containing unfiltered generated signals: SNR x loop x trial x time
        
        %MPP ESTIMATION 

        %STEP 1: Filter data
        testigfilt = filtfilt(a,b, testsig2')'; 
        testigfilt = filtfilt(ahigh,bhigh, testigfilt')';
        
        %STEPS 2 and 3: train algorithm on data to yield dictionary entries,
        %               test on data to produce MPP event structs
        [D, MPP(:, x), th_opt] = PhEv_Learn_fast_2(testigfilt, M, K);

    fprintf(['loop ' num2str(loop) ' SNR ' num2str(x) '\n'])
    
    end 

    MPPsims(loop) = {MPP}; %store dictionaries and MPP events for each loop

end

save('MPPsimsSin_.03dBto3dB.mat','MPPsims') %save dictionaries and MPP event info, change name based on signal shape and SNR range
save('MPPsimsSin_signals.03dBto3dB.mat','testsigs') %save unfiltered simulated signals
%% 4.) Unpack MPP structs to extract timining information
MPPsims2 = cell(nLoops,nSNR); %nLoop x nSNR cell array, each cell contains MPP structs for each trial group
taus = cell(trialsPerSNR,nSNR); %cell array containing MPP event latencies
taus_loops = cell(nLoops,nTrials,nSNR); %cell array containing MPP event latencies separated by trial group
taus_all = cell(nSNR,nLoops); %cell array containing MPP event latencies clustered by trial group
idx = 0:nTrials:(trialsPerSNR-nTrials); %allows for assignment of event latencies across loops and separated by SNR


%Reorganize MPP structs into cell array for easier extraction
for x = 1:nSNR
    for loop = 1:nLoops
        MPPsims2(loop,x) = {MPPsims{loop,1}(:,x)}; 
    end
end

%Extract MPP event onsets if they are detected
for x = 1:nSNR
    for loop = 1:nLoops
        for tr = 1:nTrials
            if ~isempty(MPPsims2{loop,x}(tr).Trials) %records event latencies if events detected in this trial
                taus_tr = zeros(size(MPPsims2{loop,x}(tr).Trials)); %number of events detected, changes depending on trial

                for t = 1:length(taus_tr)
                       taus_tr(t) = MPPsims2{loop,x}(tr).Trials(t).tau; %fills vector with event latencies
                end
                %assigns vector of event latencies to cell arrays
                taus(tr+idx(loop),x) = {taus_tr}; %across loops
                taus_loops(loop,tr,x) = {taus_tr}; %for each loop
                taus_all(x,loop) = {[taus_all{x,loop}, taus_tr]}; %clustered by loop
            end
        end
    end
end
%% 5.) Count the number of true detected events across SNR values and across trial groups

outmat_loops = zeros(nSNR,nLoops); %number of detected events that occur during the sine wave

for x = 1:nSNR
    for loop = 1:nLoops
        %counts number of events with latencies between 3000 and 4000, inclusive
        outmat_loops(x,loop) = length(find(taus_all{x,loop}-3000 >= 0 & taus_all{x,loop}-3000 <= 1000));
    end
end

figure, 
for l = 1:nLoops
    %plots number of true detected events as a function of SNR
    plot(outmat_loops(:,l)) %plots all loops
    hold on
end
xlabel('SNR')
ylabel('Number of detected events')
%plots number of true detected events as a function of SNR, averaged across
%loops
avgOutmat = mean(outmat_loops,2); 
plot(avgOutmat,'m','lineWidth',4)
