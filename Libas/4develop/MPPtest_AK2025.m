
clear 
filemat = getfilesindir(pwd, 'myaps2_702*.trls.g.mat');

figure(201)
figure(301)
figure(401)

% make a gaussian kernel for convolution
Gwin = gausswin(200);

% make output empty
convmat_stick = []; 
convmat_pow = []; 

for fileindex = 1:size(filemat,1)

    tmp = load(filemat(fileindex,:));

    % quick wavelet only at channel 72
    WaPower = wavelet_app_mat(tmp.Mat3D(72,:, :), 500, 11, 100, 3, []);
    faxisall = 0:0.333:250; 
    faxis = faxisall(11:3:100);
    taxis = -600:2:2000-2; 

    data = squeeze(tmp.Mat3D(72,:, :))'; % only sensor 72 for now
    
    % filter around 10 Hz
     % highpass filter
             [B,A] = butter(4,8/(500/2), 'high');
             filtereddata = filtfilt(B,A,data')'; %
             disp('highpass filter')
        
         % lowpass filter
             [B,A] = butter(4,12/(500/2));
             filtereddata = filtfilt(B,A,filtereddata')'; %
             disp('lowpass filter')
    
   % do the MPP; ak replaced smooth.m with smoothdata.m
    [D,MPP,th_opt,ar,bw] = PhEv_Learn_fast_2(filtereddata, 100, 5);

    %collect all taus
    tauvector = []; 
    for tauindex = 1:size(MPP,2)
        tauvector = [tauvector MPP(tauindex).Trials.tau];
    end

    %collect all power
    powvector = []; 
    for tauindex = 1:size(MPP,2)
        powvector = [powvector MPP(tauindex).Trials.pow];
    end

    % combine tau and power
    taupowervector = zeros(1,1300);
    taupowervector(tauvector) = powvector; 

    % convolution 1: power not used
    taustickvector = zeros(1,1300);
    taustickvector(tauvector) = 1; 
    tauconvector = conv(taustickvector, Gwin, 'same');

    % convolution 2: power not used
    taupowerconvector = conv(taupowervector, Gwin, 'same');

    % % draw the resulting data into one plot
    % figure(201)
    % subplot(6,3,3*fileindex-2), xline(sort(tauvector)), title(filemat(fileindex,:));
    % subplot(6,3,3*fileindex-1), plot(taupowervector)
    % subplot(6,3,3*fileindex), contourf(taxis, faxis, squeeze(WaPower(1,:,:))')
    % pause(.5)

    figure(301)
    hold on, plot(tauconvector), pause (.1), hold off

    figure(401)
    hold on, plot(taupowerconvector), pause (.1), hold off

    convmat_stick = [convmat_stick; tauconvector]; 
    convmat_pow = [convmat_pow; taupowerconvector]; 


end

legend

save ([filemat(1, 1:10), '.stickcon.mat'], 'convmat_stick')
save ([filemat(1, 1:10), '.powcon.mat'], 'convmat_pow')
