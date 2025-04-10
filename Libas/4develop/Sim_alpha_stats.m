%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% SIMULATION 4 MCP ak version based on anna-lena version 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


alpha_timevec  = 0:0.001:.8; % fits 8 cycles of alpha sampled at 1000 Hz
alpha_template = sin(2*pi*alpha_timevec*10); % 800 ms of 10 Hz alpha, for the baseline


%% now simulate data for each trial and participant
% first define number of subjects, trial, elecs, effects, tp...
n_trials = 40; % 
n_subj = 30;  
effects = -0.1:0.01:0.26; % 
n_effects=size(effects,2); % 
n_elec=1;
n_tp=3000; % number of time points (ms)

%%
for eff= 1:n_effects
    for subj = 1:n_subj
        for trial = 1:n_trials
            % condition 1 - has alpha template
            whitenoise = rand(n_elec,n_tp);
            tempbrown = cumsum(whitenoise'-.5);
            brownnoise = detrend(tempbrown)';
            data_trial_cond1 = brownnoise;
            data_trial_cond1(:, 1:(n_sp/2)) = data_trial_cond1(:, 1:(n_sp/2))+alpha_template*effects(eff);   % add alpha_template multiplied with effect for first second
            datatemp1(:, :, trial) = data_trial_cond1;

            % condition 2 -  has no alpha template
            whitenoise = rand(n_elec,n_sp);
            tempbrown = cumsum(whitenoise'-.5);
            brownnoise = detrend(tempbrown)';
            datatemp2(:, :, trial) = brownnoise;
        end % trial

    

        %% compute wavelet
        [WaPower_cond1] = wavelet_app_mat2(datatemp1, 100, 5, 60, 2, []);
        [WaPower_cond2] = wavelet_app_mat2(datatemp2, 100, 5, 60, 2, []);

         %% bsl correction: 300 - 600ms
        [outWaMat_cond1] = bslcorrWAMat_percent(WaPower_cond1, 30:60); % size 3D: 129x2000x28
        [outWaMat_cond2] = bslcorrWAMat_percent(WaPower_cond2, 30:60);

        % faxisall = 0:1000/lengthinms:nyquist
        % faxisall = 0:.5:125; % bei 250 Hz
        % faxis = faxisall(5:2:60);  % 9. is 10Hz

        % bei 100 Hz:
        % faxisall = 0:1000/lengthinms:nyquist
        faxisall = 0:.5:50; % bei 100 Hz
        faxis = faxisall(5:2:60);  % 9. is 10Hz

        mat4D_cond1(:, :, :, subj) = outWaMat_cond1;
        mat4D_cond2(:, :, :, subj) = outWaMat_cond2;

    end % subject

mat5D_cond1(eff, :, :, :, :)=mat4D_cond1;
mat5D_cond2(eff, :, :, :, :)=mat4D_cond2;

end % eff

%% save
save('wavelets_cond1_130effects_SR100.mat', 'mat5D_cond1', '-v7.3','-nocompression');
save('wavelets_cond2_130effects_SR100.mat', 'mat5D_cond2', '-v7.3','-nocompression');



% only save elec 72 
elec72_cond1 = squeeze(mat5D_cond1(:,72,:,:,:));
elec72_cond2 = squeeze(mat5D_cond2(:,72,:,:,:));

save('alpha_elec72_cond1_130effects_SR100.mat', 'elec72_cond1', '-v7.3','-nocompression');
save('alpha_elec72_cond2_130effects_SR100.mat', 'elec72_cond2', '-v7.3','-nocompression');





