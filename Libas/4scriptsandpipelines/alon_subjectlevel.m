% analysis with Alon, may 19th
% filemat1 = getfilesindir(pwd, '*8L*');
% filemat2 = getfilesindir(pwd, '*8R*');
% [combmat] = combineLP_alon(filemat1,filemat2);
% 
% filemat_comb = getfilesindir(pwd, '*8.comb*')
% filemat_combCor = filemat_comb(1:2:end, :)
% filemat_combInt = filemat_comb(2:2:end, :)

% filemat1 = getfilesindir(pwd, '*7L*');
% filemat2 = getfilesindir(pwd, '*7R*');
% [combmat] = combineLP_alon(filemat1,filemat2);
 
filemat_comb = getfilesindir(pwd, '*7.comb.mat')
filemat_combCor = filemat_comb(1:2:end, :)
filemat_combInt = filemat_comb(2:2:end, :)

%% participant loop 
for person = 1:21
    
    data1_r = []; 
    data2_r = []; 
    
    filename1 = deblank(filemat_combInt(person,:));
    filename2 = deblank(filemat_combCor(person,:)); 
    
    temp1 = load(filename1); 
    temp2 = load(filename2);
    
    data1 = temp1.combmat;
    data2 = temp2.combmat;
    
    Ntrials = min(size(data1, 3), size(data2, 3)); 
    
    randvec1 = randperm(size(data1, 3)); 
    randvec2 = randperm(size(data2, 3)); 
    
    data1_r(:, :, 1:Ntrials) = data1(:, :, randvec1(1:Ntrials));
    data2_r(:, :, 1:Ntrials) = data2(:, :, randvec2(1:Ntrials)); 
    
    [WaPowerInt, PLI_int, PLIdiff_int] = wavelet_app_mat(data1_r, 500, 6, 50, 1, 27, filename1);
    [WaPowerCor, PLI_Cor, PLIdiff_Cor] = wavelet_app_mat(data2_r, 500, 6, 50, 1, 27, filename2);
       
end
   %% now average and plot
   filematpow = getfilesindir(pwd, '*mat.pow3.mat')
   filematpowInt = filematpow(2:2:end, :)
   filematpowCor = filematpow(1:2:end, :)
   
   GMpowInt = avgmats_mat(filematpowInt); 
   GMpowCor = avgmats_mat(filematpowCor); 
   GMpowdiff = GMpowInt-GMpowCor; 
    
   taxis = -1300:2:100-2;
   faxisall = 0:0.7143:250;
   faxis = faxisall(6:1:50);
   
for channel = 1:30   
    subplot(3,1,1), contourf(taxis, faxis, squeeze(GMpowInt(channel, :, :))'), colorbar
    subplot(3,1,2), contourf(taxis, faxis, squeeze(GMpowCor(channel, :, :))'), colorbar
    subplot(3,1,3), contourf(taxis, faxis, squeeze(GMpowdiff(channel, :, :))'), colorbar
    title(num2str(channel))
    pause
end
   