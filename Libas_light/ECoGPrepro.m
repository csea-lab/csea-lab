function [EEGstruc, ECOGstruc, ERPstruc] = ECoGPrepro(filemat, locations, plotflag)

for fileindex = 1:size(filemat,1); 

        filepath = deblank(filemat(fileindex,:)) 
      
        data = ft_read_data(filepath);
        events = ft_read_event(filepath);
        header = ft_read_header(filepath);
        header.label;
    
        disp('filtering continuous data') 
    
         % filter data at 180 Hz lowpass
         [A,B] = butter(4,0.3,'low');   
        data = filtfilt(A,B, data')'; 

        % filter data at 0.06 Hz highpass
         [A,B] = butter(3,0.001,'high');   
        data = filtfilt(A,B, data')'; 

        % notch filter for 60 Hz
        d = fdesign.bandstop('N,F3dB1,F3dB2',20,59,61,1200);
        Hd = design(d,'butter');
        data = filter(Hd, data')';
    
      disp('done') 

    % find onset times in samples, first find indices in eventfile, then find sample in data
    % file
    onsetindices = find(strcmp({events.type},  'StimulusBegin')==1);
    onsetsamples = [(events(onsetindices).sample)]';

    %cut out the epochs of interest for the 3d matrix
    data3d = []; 
    for epoch = 1:size(onsetsamples)
        if onsetsamples(epoch)-1200 < 0, data3d(:, :, epoch) =[ rand(size(data,1), 1200) data(:, onsetsamples(epoch):onsetsamples(epoch)+2400)]; 
        else data3d(:, :, epoch) = data(:, onsetsamples(epoch)-1200:onsetsamples(epoch)+2400); end
    end

    % find picture indices in samples, same as above
    picnumindices= find(strcmp({events.type},  'StimulusCode')==1);
    picnums = [(events(picnumindices).value)]';

    % cut out epochs that belong together: 
    pleasantindices = find(picnums < 21); 
    neutralindices = find(picnums>20 & picnums < 41);
    unpleasantindices = find(picnums > 40);

    data3d_P = data3d(:, :, pleasantindices); 
    data3d_N = data3d(:, :, neutralindices); 
    data3d_U = data3d(:, :, unpleasantindices); 

    %% EEG
    % extract only EEG
    data3d_P_scalp = data3d_P(14:35,:, :);
    data3d_N_scalp = data3d_N(14:35,:, :);
    data3d_U_scalp = data3d_U(14:35,:, :);

    % interpolate bad channels
    [data3d_P_scalp, interpsensvec1] = scadsAK_3dchan(data3d_P_scalp, locations); 
    [data3d_N_scalp, interpsensvec2] = scadsAK_3dchan(data3d_N_scalp, locations); 
    [data3d_U_scalp, interpsensvec3] = scadsAK_3dchan(data3d_U_scalp, locations); 

    % find bad trials and remove them
    [data3d_P_scalp, badindex1] = scadsAK_3dtrials(data3d_P_scalp); 
    [data3d_N_scalp, badindex2] = scadsAK_3dtrials(data3d_N_scalp); 
    [data3d_U_scalp, badindex3] = scadsAK_3dtrials(data3d_U_scalp); 

    % test the data quality by just averaging (this makes only sense for the
    % scalp EEG)
    data3d_P_avg = avg_ref(mean(data3d_P_scalp, 3)); 
    data3d_N_avg = avg_ref(mean(data3d_N_scalp, 3)); 
    data3d_U_avg = avg_ref(mean(data3d_U_scalp, 3)); 

   if plotflag,
       figure,
    for eegchan = 1:22,
    plot(data3d_P_avg(eegchan,:))
    hold on, plot(data3d_N_avg(eegchan,:), 'g')
    hold on, plot(data3d_U_avg(eegchan,:), 'r'), title(locations(eegchan).labels); 
    pause, hold off
    end
   end

    % assuming data quality looks good, average-reference the 3d EEG matrix: 
    data3d_P_scalpAR = []; data3d_N_scalpAR=[];  data3d_U_scalpAR=[]; 
    
    for x1 = 1:size(data3d_P_scalp,3)
        data3d_P_scalpAR(:, :, x1) = avg_ref(squeeze(data3d_P_scalp(:, :, x1))); 
    end

    for x2 = 1:size(data3d_N_scalp,3)
    data3d_N_scalpAR(:, :, x2) = avg_ref(squeeze(data3d_N_scalp(:, :, x2))); 
    end

    for x3 = 1:size(data3d_U_scalp,3)
        data3d_U_scalpAR(:, :, x3) = avg_ref(squeeze(data3d_U_scalp(:, :, x3))); 
    end
    
     %% ECoG
    % extract only ECoG
    data3d_P_ECOG = data3d_P(2:13,:, :);
    data3d_N_ECOG = data3d_N(2:13,:, :);
    data3d_U_ECOG = data3d_U(2:13,:, :);
      
    % remove same (bad) trials as in scalp EEG, to keep same number of
    % trials
    data3d_P_ECOG(:, :, badindex1) = []; 
    data3d_N_ECOG(:, :, badindex2) = []; 
    data3d_U_ECOG(:, :, badindex3) = []; 
    
    % calculate bipolar montage for left hippocampus (and maybe amygdala)
    % and right 
    data3d_P_ECOG_bip = cat(1, [diff(data3d_P_ECOG(1:2:end, :, :), 1, 1)],  [diff(data3d_P_ECOG(2:2:end, :, :), 1, 1)]); 
    data3d_N_ECOG_bip = cat(1, [diff(data3d_N_ECOG(1:2:end, :, :), 1, 1)],  [diff(data3d_N_ECOG(2:2:end, :, :), 1, 1)]); 
    data3d_U_ECOG_bip = cat(1, [diff(data3d_U_ECOG(1:2:end, :, :), 1, 1)],  [diff(data3d_U_ECOG(2:2:end, :, :), 1, 1)]); 
    
     [data3d_P_ECOG_bip, badindexB1] = scadsAK_3dtrialsECoG(data3d_P_ECOG_bip); 
    [data3d_N_ECOG_bip, badindexB2] = scadsAK_3dtrialsECoG(data3d_N_ECOG_bip); 
    [data3d_U_ECOG_bip, badindexB3] = scadsAK_3dtrialsECoG(data3d_U_ECOG_bip); 
    pause
    
    %% clean up and append info
    %%%
    
    if fileindex==1 
        alldata3d_P_scalp = data3d_P_scalpAR; 
        alldata3d_N_scalp = data3d_N_scalpAR; 
        alldata3d_U_scalp = data3d_U_scalpAR; 
        
        alldata3d_P_ecog = data3d_P_ECOG_bip; 
        alldata3d_N_ecog = data3d_N_ECOG_bip; 
        alldata3d_U_ecog = data3d_U_ECOG_bip;       
    else
        alldata3d_P_scalp = cat(3, alldata3d_P_scalp, data3d_P_scalpAR); 
        alldata3d_N_scalp = cat(3, alldata3d_N_scalp, data3d_N_scalpAR); 
        alldata3d_U_scalp = cat(3, alldata3d_U_scalp, data3d_U_scalpAR); 
        
        alldata3d_P_ecog = cat(3, alldata3d_P_ecog, data3d_P_ECOG_bip); 
        alldata3d_N_ecog = cat(3, alldata3d_N_ecog, data3d_N_ECOG_bip); 
        alldata3d_U_ecog = cat(3, alldata3d_U_ecog, data3d_U_ECOG_bip); 
    end
      
    
end % loop over files

 EEGstruc.P = alldata3d_P_scalp; 
 EEGstruc.N = alldata3d_N_scalp; 
 EEGstruc.U = alldata3d_U_scalp; 
  
ERPstruc.P = mean(alldata3d_P_scalp, 3); 
ERPstruc.N = mean(alldata3d_N_scalp, 3); 
ERPstruc.U = mean(alldata3d_U_scalp,3); 

 [A,B] = butter(4,0.07,'low');  
 ERPstruc.P = filtfilt(A, B, ERPstruc.P')'; 
 ERPstruc.N = filtfilt(A, B, ERPstruc.N')'; 
 ERPstruc.U = filtfilt(A, B, ERPstruc.U')'; 
 
 ECOGstruc.P = alldata3d_P_ecog; 
 ECOGstruc.N = alldata3d_N_ecog;
 ECOGstruc.U = alldata3d_U_ecog;
 
 
 
 








