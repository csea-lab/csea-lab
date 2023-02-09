clear 

data = ft_read_data('010_403_p3_20180320_103240.mff');
events = ft_read_event('010_403_p3_20180320_103240.mff');

% build a lowpass filter
[a, b] = butter(4, .08); 
data = filtfilt(a, b, double(data)')'; 

% build a high filter
[ah, bh] = butter(2, .001, 'high'); 
data = filtfilt(ah, bh, data')'; 

load('/Users/andreaskeil/Documents/GitHub/csea-lab/Libas/4data/HCGSNSensorPostionFiles/GSN-HydroCel-32.sfp.mat');

% interpolate bad channels throughout
[data, interpvecthroughout] = scadsAK_2dInterpChan(data, locations);

% this is the first step after reading stuff in: 
% find the times (in sample points) where a stm+ event happened
% we think that this may be the stiimulus but estelle will find out

segmentvec = []; 
conditionvec =[]; 
for x = 1: size(events,2)    
   if strcmp(events(x).value, 'stm+')
      segmentvec = [segmentvec events(x).sample]; 
      conditionvec = [conditionvec; events(x+1).value];
   end
end


% now find the data segments and get the ERP data

mat = zeros(33, 1501, size(segmentvec,2));
for x = 1:size(segmentvec,2)
mat(:, :, x) = data(:, segmentvec(x)-500:segmentvec(x)+1000);  
end


% split in two conditions
mat_std_tmp  = mat(:, :, conditionvec==1111); 
mat_target_tmp  = mat(:, :, conditionvec==2222); 
 

% do artifact correction
% first bad channels within trials



[ mat_std, badindex, NGoodtrials ] = scadsAK_3dtrials(mat_std_tmp); 
[ mat_target, badindex, NGoodtrials ] = scadsAK_3dtrials(mat_target_tmp); 


% average
erp_std = mean(mat_std,3);
erpbsl_std = bslcorr(erp_std, 1:500);

erp_target = mean(mat_target,3);
erpbsl_target = bslcorr(erp_target, 1:500);


