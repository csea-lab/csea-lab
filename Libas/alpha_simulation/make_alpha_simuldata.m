cd '/Users/andreaskeil/Documents/GitHub/csea-lab/Libas/alpha_simulation'
nsubjects = 30;

effectsize = .1;

a = read_avr('alphafake.avr'); % read alpha topography, saved from Besa sim

b = avg_ref_add(a); % average ref with 129 as Cz added

c = resample(b, 5, 1, 'Dimension', 2); % alpha topography with alpha time course at 10 hz
% sample rate is 1000 Hz now

alpha_template = fliplr(c); 
% alpha sig starts at sample point 1, ends at 800

mat4D_1 = zeros(129, 2000, 28, nsubjects); 
mat4D_2 = zeros(129, 2000, 28, nsubjects);

data1 = zeros(129, 2000, 40); 
data2 = zeros(129, 2000, 40); 

for subject = 1:nsubjects

    for trial = 1:40
    % data1 has alpha template
        whitenoise = rand(129,2000);
        tempbrown = cumsum(whitenoise'-.5);
        brownnoise = detrend(tempbrown)';
        data_trial = brownnoise;
        data_trial(:, 1:1000) = data_trial(:, 1:1000)+alpha_template.*effectsize;
        data1(:, :, trial) = data_trial;
        
     %data2 has no alpha template 
        whitenoise = rand(129,2000);
        tempbrown = cumsum(whitenoise'-.5);
        brownnoise = detrend(tempbrown)';
        data2(:, :, trial) = brownnoise;

    end

    [WaPower1] = wavelet_app_mat(data1, 1000, 5, 60, 2, []);
    [WaPower2] = wavelet_app_mat(data2, 1000, 5, 60, 2, []);

    [outWaMat1] = bslcorrWAMat_percent(WaPower1, 300:600);
    [outWaMat2] = bslcorrWAMat_percent(WaPower2, 300:600);

    mat4D_1(:, :, :, subject) = outWaMat1;
    mat4D_2(:, :, :, subject) = outWaMat2;

end

[~, ~, ~, stats] = ttest(mat4D_1,mat4D_2,"Dim",4);
