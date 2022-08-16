function [fixoff_proport_hab, fixoff_proport_acq] = calc_off_fixation_time(matfilemat, datfilemat)
% extracts gaze data from correct eyeout.mat files and computes gaze
% locations relative to threat cue
% plots gaze density and writes out the density for the 10 conditions, in
% order 11 12 13 14 15 21 22 23 24 25
% saves the file as gazehist10.mat
% for wavelets use wavelet_gaze function

for fileindex = 1:size(matfilemat,1)
    
    matfile = deblank(matfilemat(fileindex,:)); 
    datfile =  deblank(datfilemat(fileindex,:)); 

    % eye gaze data first (matfiles)
    temp = load(matfile); 
    data = temp.eyelinkout.matcorr; 
    data = data(1:2,501:1500, : ); % no pupil, only gaze; only time points during stim on period

    % now, need to know where the threat cues was
    % on lab screen in 129 lab (CRS Display++: 1920 by 1080)
    centerhori = 1920/2;
    centerverti = 1080/2; 
    radius = 120;
    theta=linspace(0,2*pi,250); %you can increase this if this isn't enough yet
    x=radius*cos(theta);
    y=radius*sin(theta);
    positions(1,:) = [centerhori centerverti]+[x(1) y(1)];
    positions(2,:) = [centerhori centerverti]+[x(51) y(51)];
    positions(3,:) = [centerhori centerverti]+[x(101) y(101)];
    positions(4,:) = [centerhori centerverti]+[x(151) y(151)];
    positions(5,:) = [centerhori centerverti]+[x(201) y(201)];

    % conditions next
    aha = dlmread(datfile); 
    conditions = aha(1:350, 5)+[ones(150,1).*10; ones(200,1).*20];
    CSlocation = aha(1,6); 
    condivec = unique(conditions);

    % data by condition
    for con_index = 1:5
    data_hab(:, :, :, con_index) = data(:, :, conditions==condivec(con_index)); 
    end

    for con_index = 6:10
    data_acq(:, :, :, con_index-5) = data(:, :, conditions==condivec(con_index)); 
    end
    
    % transfer to fixation ccordinates
    data_hab(1,:, :, :) = data_hab(1,:, :, :)-mean(mean(mean(data_hab(1,:, :, :)))); 
    data_hab(2,:, :, :) = data_hab(2,:, :, :)-mean(mean(mean(data_hab(2,:, :, :))));
    data_acq(1,:, :, :) = data_acq(1,:, :, :)-mean(mean(mean(data_acq(1,:, :, :))));
    data_acq(2,:, :, :) = data_acq(2,:, :, :)-mean(mean(mean(data_acq(2,:, :, :))));
     
    % combine hori and verti to vector length off fixation
    off_fix_abs_hab = squeeze(sqrt(data_hab(1,:,:,:).^2 + data_hab(2,:,:,:).^2)); 
    off_fix_abs_acq = squeeze(sqrt(data_acq(1,:,:,:).^2 + data_acq(2,:,:,:).^2)); 
    
     
   % proportion outside fixation
   for ix = 1:5
   fixoff_proport_hab(fileindex, ix) = length(find(off_fix_abs_hab(:, :, ix) > 140))./length(find(off_fix_abs_hab(:, :, ix) > 0));
   end
   
   for ix = 1:5
   fixoff_proport_acq(fileindex, ix) = length(find(off_fix_abs_acq(:, :, ix) > 140))./length(find(off_fix_abs_acq(:, :, ix) > 0));
   end

end
