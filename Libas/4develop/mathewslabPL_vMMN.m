function [] = mathewslabPL_vMMN(filemat, plotflag)

ft_defaults

% sample rate is 1000 Hz

disp('new file:')

for fileindex = 1:size(filemat,1)

    disp(filemat(fileindex,:))
    
    disp(fileindex)
    
    filepath = deblank(filemat(fileindex,:));

    taxis = -500:1:1000; 

    data = ft_read_data(filepath);  % filepath is an mff file
    
    warning('off')

    events = ft_read_event(filepath);

    % build a lowpass filter
    [a, b] = butter(6, .08); 
    data = filtfilt(a, b, double(data)')'; 

    % build a highpass filter
    [ah, bh] = butter(2, .001, 'high'); 
    data = filtfilt(ah, bh, data')'; 

    load('/Users/andreaskeil/Documents/GitHub/csea-lab/Libas/4data/HCGSNSensorPostionFiles/GSN-HydroCel-32.sfp.mat');

    % interpolate bad channels throughout
    [data, interpvecthroughout] = scadsAK_2dInterpChan(data, locations, 3);

    [~,S2] = regress_eog(data', 1:32, sparse([32,31,1,29,2,30],[1,1,2,2,3,3],[1,-1,1,-1,1,-1]));
    data = (S2');

    % Segmentation
    % this is the first step after reading stuff in: 
    % find the times (in sample points) where a stim event happened
    % sst+ is the standards (in the MMN sense) and we only want those,
    % staying away from MMN deviant trials which are rare and also have
    % another event that draws attention cha 
    % these mmff file keys are the non-targets in the P3 sense for the MMN
    % standard trials: cell 1: there should be 140 per block
    % these mmff file keys are the targets in the P3 sense for the MMN: 2
    % and 3, there should be 10 per block

    segmentvec_P3_NONtarget = []; 
    conditionvec =[]; 
    for x = 1: size(events,2)    
       if strcmp(events(x).value, 'sst+') && strcmp(events(x).mffkey_cel, '1')
          segmentvec_P3_NONtarget = [segmentvec_P3_NONtarget events(x).sample]; 
          % conditionvec = [conditionvec; events(x+1).value]; this works on
          % some select few subjects
          conditionvec = [conditionvec; str2num(events(x).mffkey_cel)];
       end
    end

    segmentvec_P3_target = []; 
    conditionvec =[]; 
    for x = 1: size(events,2)    
       if strcmp(events(x).value, 'sst+') && (strcmp(events(x).mffkey_cel, '2') || strcmp(events(x).mffkey_cel, '3'))
          segmentvec_P3_target = [segmentvec_P3_target events(x).sample]; 
          % conditionvec = [conditionvec; events(x+1).value]; this works on
          % some select few subjects
          conditionvec = [conditionvec; str2num(events(x).mffkey_cel)];
       end
    end

    % now find the data segments and get the ERP data for nontargets
    mat_NONtarget = zeros(33, 1501, size(segmentvec_P3_NONtarget,2));
    for x = 1:size(segmentvec_P3_NONtarget,2)
    mat_NONtarget(:, :, x) = data(:, segmentvec_P3_NONtarget(x)-500:segmentvec_P3_NONtarget(x)+1000);  
    end

  % now find the data segments and get the ERP data for *targets*
    mat_target = zeros(33, 1501, size(segmentvec_P3_target,2));
    for x = 1:size(segmentvec_P3_target,2)
    mat_target(:, :, x) = data(:, segmentvec_P3_target(x)-500:segmentvec_P3_target(x)+1000);  
    end


    % do artifact correction
    % first bad channels within trials
    [ mat_NONtarget, badindex, NGoodtrials ] = scadsAK_3dtrials(mat_NONtarget, 1.2); 
    [ mat_target, badindex, NGoodtrials ] = scadsAK_3dtrials(mat_target, 1.2); 


    % average
    erp_std = mean(mat_NONtarget,3);
    erpbsl_std = bslcorr(erp_std, 400:500);
    erpbsl_std = avg_ref(erpbsl_std);

    erp_target = mean(mat_target,3);
    erpbsl_target = bslcorr(erp_target, 400:500);
    erpbsl_target = avg_ref(erpbsl_target);

    if plotflag
        figure(101)
        subplot(3,1,1), plot(taxis(400:end), erpbsl_std(:, 400:end)'), hold on, plot(taxis(400:end), erpbsl_std(19, 400:end), 'r', 'LineWidth', 3), title('standard')
        subplot(3,1,2), plot(taxis(400:end), erpbsl_target(:, 400:end)'), hold on, plot(taxis(400:end), erpbsl_target(19, 400:end), 'r', 'LineWidth', 3),title('target')
        subplot(3,1,3), plot(taxis(400:end), erpbsl_std(19, 400:end),  'b', 'LineWidth', 3), hold on, plot(taxis(400:end), erpbsl_target(19, 400:end), 'r', 'LineWidth', 3)
        pause(2)
    end
    hold off
    
     eval(['save ' filepath '.ERPs.mat erpbsl_std erpbsl_target -mat'])

    eval(['save ' filepath '.EEG3D.mat mat_target mat_NONtarget -mat'])
    
    fprintf('.')
    
end




