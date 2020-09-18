% first, load a subject's dat set 
filename = 'spa320.asc.eyeout.mat'; 
datfile = 'condispas_320.dat';

load(filename)
data = eyelinkout.matcorr; 

% now load and determine the conditions
temp1 = dlmread(datfile); 
conditions = temp1(1:350, 5)+[ones(150,1).*10; ones(200,1).*20];
condivec = unique(conditions);
CSplusloc = temp1(1,6); 

% wavelet parameters
faxisall = 0:0.2499:30;
faxis = faxisall(3:2:100); 
[WaPower, PLI, PLIdiff] = wavelet_app_mat(data(1:2,:, :), 500, 3, 100, 2, [], [filename '.wav']); 
WaPower_bsl = bslcorrWAMat_div(WaPower, [20: 200]); 

subplot(2,1,1), contourf(taxis, faxis, squeeze(WaPower_bsl(1,:, :))'), title('horizontal gaze'); colorbar
subplot(2,1,2), contourf(taxis, faxis, squeeze(WaPower_bsl(2,:, :))'), title('vertical gaze');colorbar

% now do this by condition
gaze11= (data(:,:,conditions==11)); 
gaze12= (data(:,:,conditions==12)); 
gaze13= (data(:,:,conditions==13)); 
gaze14= (data(:,:,conditions==14)); 
gaze15= (data(:,:,conditions==15)); 
gaze21= (data(:,:,conditions==21)); 
gaze22= (data(:,:,conditions==22)); 
gaze23= (data(:,:,conditions==23)); 
gaze24 = (data(:,:,conditions==24)); 
gaze25 = (data(:,:,conditions==25)); 

[WaPower11, PLI, PLIdiff] = wavelet_app_mat(gaze11, 500, 3, 100, 2, [], [filename '.11wav']); 
[WaPower12, PLI, PLIdiff] = wavelet_app_mat(gaze12, 500, 3, 100, 2, [], [filename '.12wav']); 
[WaPower13, PLI, PLIdiff] = wavelet_app_mat(gaze13, 500, 3, 100, 2, [], [filename '.13wav']); 
[WaPower14, PLI, PLIdiff] = wavelet_app_mat(gaze14, 500, 3, 100, 2, [], [filename '.14wav']); 
[WaPower15, PLI, PLIdiff] = wavelet_app_mat(gaze15, 500, 3, 100, 2, [], [filename '.15wav']); 
[WaPower21, PLI, PLIdiff] = wavelet_app_mat(gaze21, 500, 3, 100, 2, [], [filename '.21wav']); 
[WaPower22, PLI, PLIdiff] = wavelet_app_mat(gaze22, 500, 3, 100, 2, [], [filename '.22wav']); 
[WaPower23, PLI, PLIdiff] = wavelet_app_mat(gaze23, 500, 3, 100, 2, [], [filename '.23wav']); 
[WaPower24, PLI, PLIdiff] = wavelet_app_mat(gaze24, 500, 3, 100, 2, [], [filename '.24wav']); 
[WaPower25, PLI, PLIdiff] = wavelet_app_mat(gaze25, 500, 3, 100, 2, [], [filename '.25wav']); 

WaPower11_bsl = bslcorrWAMat_div(WaPower11, [20: 200]); 
WaPower12_bsl = bslcorrWAMat_div(WaPower12, [20: 200]); 
WaPower13_bsl = bslcorrWAMat_div(WaPower13, [20: 200]); 
WaPower14_bsl = bslcorrWAMat_div(WaPower14, [20: 200]); 
WaPower15_bsl = bslcorrWAMat_div(WaPower15, [20: 200]); 

WaPower21_bsl = bslcorrWAMat_div(WaPower21, [20: 200]); 
WaPower22_bsl = bslcorrWAMat_div(WaPower22, [20: 200]); 
WaPower23_bsl = bslcorrWAMat_div(WaPower23, [20: 200]); 
WaPower24_bsl = bslcorrWAMat_div(WaPower24, [20: 200]); 
WaPower25_bsl = bslcorrWAMat_div(WaPower25, [20: 200]); 

figure(9)
subplot(5,1,1), contourf(taxis, faxis, squeeze(WaPower11_bsl(1,:, :))'), title('horizontal gaze'); colorbar
subplot(5,1,2), contourf(taxis, faxis, squeeze(WaPower12_bsl(1,:, :))'), title('horizontal gaze'); colorbar
subplot(5,1,3), contourf(taxis, faxis, squeeze(WaPower13_bsl(1,:, :))'), title('horizontal gaze'); colorbar
subplot(5,1,4), contourf(taxis, faxis, squeeze(WaPower14_bsl(1,:, :))'), title('horizontal gaze'); colorbar
subplot(5,1,5), contourf(taxis, faxis, squeeze(WaPower15_bsl(1,:, :))'), title('horizontal gaze'); colorbar
figure(10)
subplot(5,1,1), contourf(taxis, faxis, squeeze(WaPower21_bsl(1,:, :))'), title('horizontal gaze'); colorbar
subplot(5,1,2), contourf(taxis, faxis, squeeze(WaPower22_bsl(1,:, :))'), title('horizontal gaze'); colorbar
subplot(5,1,3), contourf(taxis, faxis, squeeze(WaPower23_bsl(1,:, :))'), title('horizontal gaze'); colorbar
subplot(5,1,4), contourf(taxis, faxis, squeeze(WaPower24_bsl(1,:, :))'), title('horizontal gaze'); colorbar
subplot(5,1,5), contourf(taxis, faxis, squeeze(WaPower25_bsl(1,:, :))'), title('horizontal gaze'); colorbar




