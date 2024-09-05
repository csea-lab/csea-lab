function [] = WurzEEGlab2WaPow(filemat)

for index = 1:size(filemat, 1)
%    disp(['Loading file: ', filemat(index,:)])
   temp = load(filemat(index,:));

    temp2_threat = avg_ref_add3d(double(temp.EEG_CerThreat.data)); 
    temp2_PoThreat = avg_ref_add3d(double(temp.EEG_PoThreat.data)); 
    temp2_Safe = avg_ref_add3d(double(temp.EEG_Safe.data)); 


   % now do three wavelet analyses
    wavelet_app_mat(temp2_threat, 500, 50, 300, 10, 72, [filemat(index,1:15) '.CerThreat']);
    wavelet_app_mat(temp2_PoThreat, 500, 50, 300, 10, 72, [filemat(index,1:15) '.PoThreat']);
    wavelet_app_mat(temp2_Safe, 500, 50, 300, 10, 72, [filemat(index,1:15) '.Safe']);

end

% also put axes here for convenience

freqres = 1000/10400;  % the resolution 1 over duration of the segment from prepro
faxis_all = 0:freqres:250; % we can go from zero to nyquist  = 500 Hz/2 = 250 Hz

faxis = faxis_all(50:10:300);
taxis  = -400:2:10000-2; 

%%
% now we wish to look at the mean of the power 
filemat = getfilesindir(pwd, '*.pow3.mat');


filemat1 = filemat(1:3:end,:)
filemat2 = filemat(2:3:end,:)
filemat3 = filemat(3:3:end,:)

avgmats_mat(filemat3, 'GM46.pow3.app3.mat');
avgmats_mat(filemat2, 'GM46.pow3.app2.mat');
avgmats_mat(filemat1, 'GM46.pow3.app1.mat');

load('GM46.pow3.app1.mat')
avgmat1 = avgmat;
load('GM46.pow3.app2.mat')
avgmat2 = avgmat;
load('GM46.pow3.app3.mat')
avgmat3 = avgmat;

figure
subplot(3,1,1), contourf(taxis, faxis, squeeze(avgmat1(72,:, :))', 15)
subplot(3,1,2), contourf(taxis, faxis, squeeze(avgmat2(72,:, :))', 15)
subplot(3,1,3), contourf(taxis, faxis, squeeze(avgmat3(72,:, :))', 15)

% now with baseline cprrection
avgmatbsl1 = bslcorrWAMat_percent(avgmat1, 50:200);
avgmatbsl2 = bslcorrWAMat_percent(avgmat2, 50:200);
avgmatbsl3 = bslcorrWAMat_percent(avgmat3, 50:200);

figure
elec = 87
subplot(3,1,1), contourf(taxis(50:end-50), faxis(2:end-5), squeeze(avgmatbsl1(elec,50:end-50, 2:end-5))', 15), caxis([-30 10]), colorbar
subplot(3,1,2), contourf(taxis(50:end-50), faxis(2:end-5), squeeze(avgmatbsl2(elec,50:end-50, 2:end-5))', 15), caxis([-30 10]), colorbar
subplot(3,1,3), contourf(taxis(50:end-50), faxis(2:end-5), squeeze(avgmatbsl3(elec,50:end-50, 2:end-5))', 15), caxis([-30 10]), colorbar

%%
% % now we look at the grand average of the PLI and and intersite phase
% % locking 
% 
% % now we wish to look at the grand mean of the PLI 
% filemat = getfilesindir(pwd, '*.pli3.mat');
% 
% % average the pli from the subjects
% avgmat  = avgmats_mat(filemat, 'GM3.3conditions.pli3.mat');
% 
% % now plot the data, 
% figure, contourf(taxis(50:end-50), faxis, squeeze(avgmat(72,50:end-50, :))'); colorbar
% 
% % now we do it by condition
% 
% filemat1 = filemat(1:3:end,:)
% filemat2 = filemat(2:3:end,:)
% filemat3 = filemat(3:3:end,:)
% 
% avgmats_mat(filemat3, 'GM21.pli3.app3.mat');
% avgmats_mat(filemat2, 'GM21.pli3.app2.mat');
% avgmats_mat(filemat1, 'GM21.pli3.app1.mat');
% load('GM21.pli3.app1.mat')
% avgmat1 = avgmat;
% load('GM21.pli3.app2.mat')
% avgmat2 = avgmat;
% load('GM21.pli3.app3.mat')
% avgmat3 = avgmat;
% 
% figure
% elec = 72
% subplot(3,1,1), contourf(taxis(50:end-50), faxis(2:end), squeeze(avgmat1(elec,50:end-50, 2:end))', 15), caxis([ 0 0.28]), colorbar
% subplot(3,1,2), contourf(taxis(50:end-50), faxis(2:end), squeeze(avgmat2(elec,50:end-50, 2:end))', 15), caxis([ 0 0.28]), colorbar
% subplot(3,1,3), contourf(taxis(50:end-50), faxis(2:end), squeeze(avgmat3(elec,50:end-50, 2:end))', 15), caxis([ 0 0.28]), colorbar
