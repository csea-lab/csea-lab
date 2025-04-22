% Script for pupil myaps - Faith 

cd '/Users/faithgilbert/Desktop/1_MyAps/Paper/pupil'

% make matrices that match, start wit myaps 1
filemat_edf = getfilesindir(pwd, 'MyAp5*edf');
filemat_dat = getfilesindir(pwd, 'myaps5*');

for subject = 1:size(filemat_dat,1)

 [matcorr, matout, matoutbsl, percentbadvec, percentbadsub, percentbadcond] = eye_pipeline(filemat_edf(subject,:), 500, 'getcon_MyAPS1', filemat_dat(subject,:), 'cue_on', 250, 2000, []);   

end

% myaps 2
filemat_edf = getfilesindir(pwd, 'MyA2*edf');
filemat_dat = getfilesindir(pwd, 'myaps2*');

for subject = 1:size(filemat_dat,1)

 [matcorr, matout, matoutbsl, percentbadvec, percentbadsub, percentbadcond] = eye_pipeline(filemat_edf(subject,:), 500, 'getcon_MyAPS2_ERP', filemat_dat(subject,:), 'cue_on', 250, 2000, 0);   

end

%% this is for the averaging

% version 1
% VISUALIZE
filemat1 = getfilesindir(pwd, 'MyAp*out.mat');

data = []; 
figure

for subject = 1:size(filemat1,1)

    temp = load(filemat1(subject,:));
    datatemp = temp.matout; 

    cali1 = mean(mean(datatemp)); 
    
    if subject >= 25
        datatransform = (datatemp./cali1).*1000;
        [data] = bslcorr(datatransform', 1:250)';
    else subject < 25
        [data] = bslcorr(datatemp', 1:250)';
    end

    hold on
    plot(data(:, 1), 'b')
    plot(data(:, 2), 'k')
    plot(data(:, 3), 'r')
    plot(data(:, 5), 'b--')
    plot(data(:, 6), 'k--')
    plot(data(:, 7), 'r--')
    pause
    hold off
    clf

      if subject ==1 
        v1grand_sum = data; 
    else
        v1grand_sum = v1grand_sum + data; 
    end

end

v1grand_mean = v1grand_sum./size(filemat1,1); 

% EXTRACT STATS
% Create matrix for pupil data + baseline correct
pupilmat =[]; 
filemat1 = getfilesindir(pwd, 'MyAp*out.mat');

for x = 1:59
temp = load(filemat1(x,:)); datatemp = temp.matout; cali1 = mean(mean(datatemp));

    if x >= 25
        datatransform = (datatemp./cali1).*1000;
        [data] = bslcorr(datatransform(:, 1:8)', 1:250)';
    else x < 25
        [data] = bslcorr(datatemp(:, 1:8)', 1:250)';
    end

datanew = (data*10)/5222
pupilmat(:, :, x) = datanew; 

end

% average across timepoints
v1_gm_time = []
v1_gm_time(:, :) = mean(pupilmat(751:1751, :, :));
v1_gm_time = v1_gm_time'


%% version 2
% VISUALIZE
filemat2 = getfilesindir(pwd, 'MyA2*out.mat');
data = [];

for subject = 1:size(filemat2,1)

    temp = load(filemat2(subject,:));
    datatemp = temp.matout;     
    [data] = bslcorr(datatemp', 1:250)';
    
    hold on
    plot(data(:, 1), 'b')
    plot(data(:, 2), 'k')
    plot(data(:, 3), 'r')
    plot(data(:, 4), 'b--')
    plot(data(:, 5), 'k--')
    plot(data(:, 6), 'r--')
    pause
    hold off
    clf

      if subject ==1 
        v2grand_sum = data; 
    else
        v2grand_sum = v2grand_sum + data; 
    end

end

v2grand_mean = v2grand_sum./size(filemat2,1); 

% EXTRACT STATS
% Create matrix for pupil data + baseline correct
pupilmat =[]; 
filemat2 = getfilesindir(pwd, 'MyA2*out.mat');
for x = 1:46
temp = load(filemat2(x,:)); [matout_all] = bslcorr(temp.matout(:, 1:6)', 1:250)'
datanew = (matout_all*10)/5222
pupilmat(:, :, x) = datanew; 
fprintf('.');
end
disp('done')

% average across timepoints
v2_gm_time = []
v2_gm_time(:, :) = mean(pupilmat(751:1251, :, :));
v2_gm_time = v2_gm_time'


%% for the validation 
filemat = getfilesindir(pwd, '*.edf');

outvec =[];

for x = 1:size(filemat,1)

test = Edf2Mat(filemat(x,:));

disp(filemat(x,:))
disp("this is the mean:")
disp(mean(test.Samples.pupilSize(test.Samples.pupilSize~=0)))

outvec(filemat) = mean(test.Samples.pupilSize(test.Samples.pupilSize~=0));

end
