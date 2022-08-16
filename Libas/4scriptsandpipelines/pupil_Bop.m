function [matcorr, pupilbycond, percentbadvec] = pupil_Bop(ascfile, datfile)
%post processing: 
%edfconverter in app on the mac
%download from sr (eye link forum). 
%converts edf to .asc

pupilbycond = [];

filepath = ascfile; 

temp1 = dlmread(datfile); 

conditions = temp1(1:350, 5)+[ones(150,1).*10; ones(200,1).*20];

condivec = unique(conditions)

%then use read_edf_asc.m (should be in libas) 
asc = read_edf_asc(filepath);

%to get the indices of a given message: here it is "cue on"
 trialindexinMSGvec = []; for x = 1:length(asc.msg), if findstr('cue_on', char(asc.msg(x))), trialindexinMSGvec = [trialindexinMSGvec x], end, end

msgsubmat = char(asc.msg(trialindexinMSGvec))

start = findstr(msgsubmat(1,:), char(9)) + 1;
stop = min(findstr(msgsubmat(1,:), ' '));

startbins = str2num(msgsubmat(:, start:stop))

% plot pupil vs trials: 
figure
plot(asc.dat(1,:), asc.dat(4,:))
hold on
plot(startbins, 200, '*')

% find indices for trial segmentation, i.e. timestamps of stim onsets
[test1, loc1] = ismember(startbins, asc.dat(1,:));
[test2, loc2] = ismember(startbins-1, asc.dat(1,:)); % they might be off by one point
indices = loc1 + loc2;

if sum(indices==0) > 0, disp('check for missed triggers') , end

% put in mat format chan (3) by time by trials.. important: 
%looks like ethernet message takes 200 ms to initialize and then send to eye link out of psychtoolbox

taxis = -4000:2:2000;
mat = zeros(3, 3001, 130);
for x = 1:size(indices,1)
mat(:, :, x) = asc.dat(2:4,indices(x)-2000:indices(x)+1000);  
end

% plot the data
figure
for x = 1:130
plot(taxis, mat(:,:,x)'), title (['trial number:' num2str(x)]), pause(.1)
end

% just the pupil
figure
plot(taxis, squeeze(mat(3,:,:)))

% % or plot over time
% test = mat(:, :, 6); 
% figure, image(ones(1050, 1680)); h1 = gca; hold on, 
% comet(h1, test(1,1:10:end), test(2,1:10:end))

%%%%%%%%%%%%%
% artifact correct
 ascorr = asc;

% identify points in each epoch were all are zero and set to nans
ind_zeros =  find(asc.dat(4, :) == 0);
ascorr.dat(2:4, ind_zeros) = NaN;

% identify points where pupli changes too fast and set to nans
ind_slope =  find(abs(diff(asc.dat(4, :))) > 2.5);
ascorr.dat(2:4, ind_slope) = NaN;

% pick up the surrounding points after filtering
[filta, filtb] = butter(6, .03);
rawfilt = filtfilt(filta, filtb, abs(diff(asc.dat(4,:))));
ind_nearslope =  find(rawfilt > 5);
ascorr.dat(2:4, ind_nearslope) = NaN;

% identify points where saccade velocity exceeds max and set to nans
ind_slope =  find(abs(diff(asc.dat(2, :))) > 100.0);
ascorr.dat(2:4, ind_slope) = NaN;
nans = isnan(ascorr.dat(2,:)); % all channels (hori and vert) have the same elements as nans as pupil

% find out per trial how many NaNs
for x = 1:size(indices,1)
percentbadvec(x)= (sum(isnan(ascorr.dat(2,indices(x)-500:indices(x)+1500)))./length(mat(1,:,1))).*100; 
end

% replace all NaNs in x with linearly interpolated values
ascorr.dat(2,nans) = interp1(ascorr.dat(1,~nans), ascorr.dat(2, ~nans), ascorr.dat(1,nans), 'pchip');
ascorr.dat(3, nans) = interp1(ascorr.dat(1,~ nans), ascorr.dat(3, ~nans), ascorr.dat(1,nans), 'pchip');
ascorr.dat(4, nans) = interp1(ascorr.dat(1,~ nans), ascorr.dat(4, ~nans), ascorr.dat(1,nans), 'pchip');

% put in mat format chan (3) by time by trials
matcorr = zeros(3, 3001, 130);
for x = 1:size(indices,1)
matcorr(:, :, x) = ascorr.dat(2:4,indices(x)-2000:indices(x)+1000);  end

% plot the data
figure
for x = 1:130
plot(taxis, matcorr(:,:,x)'), title (['CORRECTED - trial number:' num2str(x)]), pause(.5)
end


% plot the trials: pupil
figure, plot(taxis, squeeze((matcorr(3,:,:)))), title('all pupil trials') 

% plot averages: pupil
figure
for condi = 1:1
    hold on,  
        if condi == 1, plot(taxis, squeeze(mean(matcorr(3,:,:), 3)), '--ks', 'LineWidth',2)
        else
        
        end
end

% plot data for gaze location
figure, subplot(2,1,1), plot(taxis, squeeze((matcorr(1,:,:)))), title('horizontal') 
subplot(2,1,2), plot(taxis, squeeze((matcorr(2,:,:)))), title('vertical') 

   
% pupil by condition
for condi = 1:10
   pupilbycond(condi,:) = squeeze(mean(matcorr(3,:,conditions==condivec(condi)), 3)); 
end

% assemble output and save
eyelinkout.pupilbycond = pupilbycond; 
eyelinkout.matcorr = matcorr; 
eyelinkout.percentbadvec = percentbadvec; 

eval(['save ' filepath '.eyeout.mat eyelinkout -mat'])

