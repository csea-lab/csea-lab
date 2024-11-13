cd '/Users/andreaskeil/Documents/GitHub/csea-lab/Libas/alpha_simulation'

a = read_avr('alphafake.avr'); % read alpha topography, saved from Besa sim

b = avg_ref_add(a); % average ref with 129 as Cz added

c = resample(b, 5, 1, 'Dimension', 2); % alpha topography with alpha time course at 10 hz
% sample rate is 1000 Hz now

alpha_template = fliplr(c); 
% alpha sig starts at sample point 1, ends at 800

datatemp = zeros(129, 2000, 40); 

for trial = 1:40

    whitenoise = rand(129,2000); 
    tempbrown = cumsum(whitenoise'-.5);
    brownnoise = detrend(tempbrown)';
    data_trial = brownnoise; 
    data_trial(:, 1:1000) = data_trial(:, 1:1000)+alpha_template; 
    datatemp(:, :, trial) = data_trial;

end

[WaPower, PLI, PLIdiff] = wavelet_app_mat(datatemp, 1000, 5, 60, 2, [], []);