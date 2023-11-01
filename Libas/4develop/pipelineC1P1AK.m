%% read in and filter data
clear 

data = ft_read_data('c1p1_532_20221027.RAW');

events = ft_read_event('c1p1_532_20221027.RAW');

codes = load("event_codes_c1p1_test.txt");

disp('done with reading')

 % build a lowpass filter
    [a, b] = butter(4, .08); 
    data = filtfilt(a, b, double(data)')'; 

% build a highpass filter
    [ah, bh] = butter(2, .001, 'high'); 
    data = filtfilt(ah, bh, data')'; 

disp('done with filtering')

%% segmentation

for cy = 1:length(events)
temptrigs(cy) = events(cy).sample;
end

newtrigvec = []; 

indiceswithtrigs = find(diff(temptrigs) > 9); 

newtrigvec_temp = temptrigs(indiceswithtrigs+1);

newtrigvec = [temptrigs(1); newtrigvec_temp']; 

for segindex = 1:4800

    data3d(:, :, segindex) = data(:, newtrigvec(segindex)-200:newtrigvec(segindex)+300);

end

disp('done with segmentation')

%% assign conditions
%standards
index1 = find(codes==1); % left stim, left attended
index11= find(codes==11); % right stim, left attended
index2 = find(codes==2); % left stim, right attended
index10 = find(codes==10); % right stim, left attended

% targets
index20= find(codes==20);
index21= find(codes==21);
index31= find(codes==31);
index30= find(codes==30);

%ERPs from the conditions
ERP_1 = mean(data3d(:, :, index1), 3); 
ERP_2 = mean(data3d(:, :, index2), 3); 
ERP_10 = mean(data3d(:, :, index10), 3); 
ERP_11 = mean(data3d(:, :, index11), 3); 

ERP_20 = mean(data3d(:, :, index20), 3); 
ERP_21 = mean(data3d(:, :, index21), 3); 
ERP_31 = mean(data3d(:, :, index31), 3); 
ERP_30 = mean(data3d(:, :, index30), 3); 


