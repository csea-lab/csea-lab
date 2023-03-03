function [erpbsl_std, erpbsl_target] = mathewslabPL(filemat, plotflag)

% sample rate is 1000 Hz

disp('new file:')


for fileindex = 1:size(filemat,1)
    
    fileindex
    
    filepath = deblank(filemat(fileindex,:))

    taxis = -500:1:1000; 

    data = ft_read_data(filepath);  % filepath is an mff file
    events = ft_read_event(filepath);

    % build a lowpass filter
    [a, b] = butter(4, .08); 
    data = filtfilt(a, b, double(data)')'; 

    % build a highpass filter
    [ah, bh] = butter(2, .001, 'high'); 
    data = filtfilt(ah, bh, data')'; 

    load('/Users/andreaskeil/Documents/GitHub/csea-lab/Libas/4data/HCGSNSensorPostionFiles/GSN-HydroCel-32.sfp.mat');

    % interpolate bad channels throughout
    [data, interpvecthroughout] = scadsAK_2dInterpChan(data, locations, 3);

    % this is the first step after reading stuff in: 
    % find the times (in sample points) where a stm+ event happened
    % we think that this may be the stiimulus but estelle will find out

    segmentvec = []; 
    conditionvec =[]; 
    for x = 1: size(events,2)    
       if strcmp(events(x).value, 'stm+')
          segmentvec = [segmentvec events(x).sample]; 
          % conditionvec = [conditionvec; events(x+1).value]; this works on
          % some select few subjects
          conditionvec = [conditionvec; str2num(events(x).mffkey_cel)];
       end
    end

    hist(conditionvec)


    % now find the data segments and get the ERP data
    mat = zeros(33, 1501, size(segmentvec,2));
    for x = 1:size(segmentvec,2)
    mat(:, :, x) = data(:, segmentvec(x)-500:segmentvec(x)+1000);  
    end


    % split in two conditions
    mat_std_tmp  = mat(:, :, conditionvec==1); % attention have to change to 2222 and 1111 for the first few subjects
    mat_target_tmp  = mat(:, :, conditionvec==2); 


    % do artifact correction
    % first bad channels within trials
    [ mat_std, badindex, NGoodtrials ] = scadsAK_3dtrials(mat_std_tmp); 
    [ mat_target, badindex, NGoodtrials ] = scadsAK_3dtrials(mat_target_tmp); 


    % average
    erp_std = mean(mat_std,3);
    erpbsl_std = bslcorr(erp_std, 400:500);
    erpbsl_std = avg_ref(erpbsl_std);

    erp_target = mean(mat_target,3);
    erpbsl_target = bslcorr(erp_target, 400:500);
    erpbsl_target = avg_ref(erpbsl_target);

    if plotflag
        subplot(2,1,1), plot(taxis(400:end), erpbsl_std(:, 400:end)'), hold on, plot(taxis(400:end), erpbsl_std(19, 400:end), 'r', 'LineWidth', 3), title('standard')
        subplot(2,1,2), plot(taxis(400:end), erpbsl_target(:, 400:end)'), hold on, plot(taxis(400:end), erpbsl_target(19, 400:end), 'r', 'LineWidth', 3),title('target')
   pause(2)
    end
    
    eval(['save ' filepath(1:14) 'ERPs.mat erpbsl_std erpbsl_target -mat'])
    
    fprintf('.')
    
end




