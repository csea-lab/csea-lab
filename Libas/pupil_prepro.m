%% pre-processing 
    for file = 1:size(filemat,1)
     datamat = Edf2Mat(filemat(file,:));
    % 
    % load(filematME(file,:));
    
    temp = ismember(test_eye.Events.Messages.info,'cue_on');
    cue_indx = find(temp);
    
    %gets cue time indexes
    for index = 1:size(cue_indx,2)
    time_indx(index) = datamat.Events.Messages.time(cue_indx(index));
    end
    
    %gets rid of times that are too close together
    for point = 1:size(time_indx(:,1:end-1),2)
    if time_indx(point+1) - time_indx(point) < 1100
    time_indx(:,point) = NaN;
    time_indx(:,point+1) = NaN;
    end
    end
    
    %round odd timepoints down
    round_time = [];
    for i=1:size(time_indx,2) % start of the list
    if mod(time_indx(:,i),2)==0
    round_time(:,i) = time_indx(:,i);
    else
    round_time(:,i)=time_indx(:,i)-1; % decrease sum of odd number by 1
    end
    end
    
    %match sample points to time points
    samplepoints = datamat.Samples.time;
    [sharedvals,idx,event_sample] = intersect(round_time',samplepoints,'rows');
    
    %get the pupil and gaze data in sample points
    pupil = datamat.Samples.pupilSize;
    horz = datamat.Samples.posX;
    vert = datamat.Samples.posY;
    
    %epoching
    taxis = -9000:2:4000;
    mat = zeros(3, 6501, length(event_sample));
    for x = 1:size(event_sample,1)
    pupilmat(:, x) = pupil(event_sample(x)-4500:event_sample(x)+2000);
    horzmat(:, x) = horz(event_sample(x)-4500:event_sample(x)+2000);
    vertmat(:, x) = vert(event_sample(x)-4500:event_sample(x)+2000);
    end
    %
    % %plot the pupil data for each trial
    % figure
    % for x = 1:size(event_sample,1)
    % plot(taxis, pupilmat(:,x)'), title (['trial number:' num2str(x)]), pause(.1)
    % end
    %%%%%%%%%%%%%
    % artifact correct
    matcorr = [samplepoints'; horz'; vert'; pupil'];
    
    % identify points in each epoch were all are zero and set to nans
    ind_zeros =  find(pupil == 0);
    matcorr(2:4, ind_zeros) = NaN;
    
    % identify points where pupli changes too fast and set to nans
    ind_slope =  find(abs(diff(pupil)) > 2.5);
    matcorr(2:4, ind_slope) = NaN;
    
    % pick up the surrounding points after filtering
    [filta, filtb] = butter(6, .03);
    rawfilt = filtfilt(filta, filtb, abs(diff(pupil)));
    ind_nearslope =  find(rawfilt > 5);
    matcorr(2:4, ind_nearslope) = NaN;
    
    % identify points where saccade velocity exceeds max and set to nans
    ind_slope =  find(abs(diff(horz)) > 100.0);
    matcorr(2:4,  ind_slope) = NaN;
    
    % find out per trial how many NaNs
    for x = 1:size(event_sample,1)
    percentbadvec(x)= (sum(isnan(matcorr(2,event_sample(x)-4500:event_sample(x)+2000)))./length(mat(1,:,1))).*100;
    end
    nans = isnan(matcorr(2,:)); % all channels (hori and vert) have the same elements as nans as pupil
    
    % replace all NaNs in x with linearly interpolated values
    matcorr(2,nans) = interp1(matcorr(1,~ nans), matcorr(2, ~nans), matcorr(1,nans), 'pchip');
    matcorr(3, nans) = interp1(matcorr(1,~ nans),matcorr(3, ~nans), matcorr(1,nans), 'pchip');
    matcorr(4, nans) = interp1(matcorr(1,~ nans), matcorr(4, ~nans), matcorr(1,nans), 'pchip');
    
    % put in mat format chan (3) by time by trials
    matcorr3d = zeros(3, 6501, 120);
    for x = 1:size(event_sample,1)
    matcorr3d(:, :, x) = matcorr(2:4,event_sample(x)-4500:event_sample(x)+2000);end
    
    % % plot the data
    % figure
    % for x = 1:size(event_sample,1)
    % plot(taxis, matcorr3d(:,:,x)'), title (['CORRECTED - trial number:' num2str(x)]), pause(.3)
    % end
    
    eval(['save ' deblank(filemat(file,1:end-4)) '.con.mat -mat']);
     end %file loop

 