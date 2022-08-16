% analysis with Alon, may 19th
% filemat1 = getfilesindir(pwd, '*8L*');
% filemat2 = getfilesindir(pwd, '*8R*');
% [combmat] = combineLP_alon(filemat1,filemat2);
% 
% filemat_comb = getfilesindir(pwd, '*8.comb*')
% filemat_combCor = filemat_comb(1:2:end, :)
% filemat_combInt = filemat_comb(2:2:end, :)

filemat1 = getfilesindir(pwd, '*7L*');
filemat2 = getfilesindir(pwd, '*7R*');
[combmat] = combineLP_alon(filemat1,filemat2);
 
filemat_comb = getfilesindir(pwd, '*7.comb.mat')
filemat_combCor = filemat_comb(1:2:end, :)
filemat_combInt = filemat_comb(2:2:end, :)

%% build 3 D arrays
% first correct trials
outmatCor =[]; 
for subject = 1:size(filemat_combCor,1)   
   temp = load(deblank(filemat_combCor(subject,:))); 
   outmatCor = cat(3, outmatCor, temp.combmat);
end
 
% now intrusion trials
outmatInt =[]; 
for subject = 1:size(filemat_combInt,1)   
   temp = load(deblank(filemat_combInt(subject,:))); 
   outmatInt = cat(3, outmatInt, temp.combmat);
end
 
%% run wavelets
% for cond 8 input is 6, 50, 2; faxisall = 0:.6666:250;
% for condition 7 input is 6, 50, 1, faxisall = 0:0.7143:250;
[WaPowerInt, PLI_int, PLIdiff_int] = wavelet_app_mat(outmatInt, 500, 6, 50, 1, 27, 'alltrials_int');
[WaPowerCor, PLI_Cor, PLIdiff_Cor] = wavelet_app_mat(outmatCor, 500, 6, 50, 1, 27, 'alltrials_Cor');

%% ensure trial count is the same 
temp = randperm(size(outmatInt,3));
randvec = temp(1:size(outmatCor,3));

outmatInt_r = outmatInt(:, :, randvec); 
%% run wavelet on trial-eqauted data
[WaPowerInt, PLI_int, PLIdiff_int] = wavelet_app_mat(outmatInt_r, 500, 6, 50, 1, 27, 'alltrials_int');
%% plot the data 
% power
faxisall = 0:0.7143:250;
faxis = faxisall(6:1:50);
taxis = -1300:2:100-2; 
diffpow = WaPowerInt-WaPowerCor; 

for channel = 1:30   
    subplot(3,1,1), contourf(taxis, faxis, squeeze(WaPowerInt(channel, :, :))'), colorbar
    subplot(3,1,2), contourf(taxis, faxis, squeeze(WaPowerCor(channel, :, :))'), colorbar
    subplot(3,1,3), contourf(taxis, faxis, squeeze(diffpow(channel, :, :))'), colorbar
    title(num2str(channel))
    pause
end
    
% PLI
figure
faxisall = 0:.6666:250;
faxis = faxisall(6:2:50);
taxis = -1400:2:100-2; 
diffpli = PLI_int-PLI_Cor; 

for channel = 1:30   
    subplot(3,1,1), contourf(taxis, faxis, squeeze(PLI_int(channel, :, :))'), colorbar
    subplot(3,1,2), contourf(taxis, faxis, squeeze(PLI_Cor(channel, :, :))'), colorbar
    subplot(3,1,3), contourf(taxis, faxis, squeeze(diffpli(channel, :, :))'), colorbar
    title(num2str(channel))
    pause
end
  
% plidiff
figure
faxisall = 0:.6666:250;
faxis = faxisall(6:2:50);
taxis = -1400:2:100-2; 
diffplidiff = PLIdiff_int-PLIdiff_Cor; 

for channel = 1:30   
    subplot(3,1,1), contourf(taxis, faxis, squeeze(PLIdiff_int(channel, :, :))'), colorbar
    subplot(3,1,2), contourf(taxis, faxis, squeeze(PLIdiff_Cor(channel, :, :))'), colorbar
    subplot(3,1,3), contourf(taxis, faxis, squeeze(diffplidiff(channel, :, :))'), colorbar
    title(num2str(channel))
    pause
end


    
