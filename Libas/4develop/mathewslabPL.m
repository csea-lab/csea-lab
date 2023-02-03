data = ft_read_data('010_403_p3_20180320_103240.mff');
events = ft_read_event('010_403_p3_20180320_103240.mff');

% build a filter
[a, b] = butter(4, .08); 
data = filtfilt(a, b, data')'; 

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


% do artifact correction


% average

erp = mean(mat,3);
erpbsl = bslcorr(erp, 1:500);