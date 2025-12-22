
cd /Users/andreaskeil/As_Exps/SONY/MPP_Topos
filemat_theta1 = getfilesindir(pwd, '*theta*11*');
filemat_theta2 = getfilesindir(pwd, '*theta*12*');

%first, give them all 129 channels
for index1 = 1: size(filemat_theta1, 1)
    a = ReadAvgFile(deblank(filemat_theta1(index1,:)));
    ref = avg_ref_add_contingent(a);
    SaveAvgFile(deblank(filemat_theta1(index1,:)), ref);
end

for index1 = 1: size(filemat_theta2, 1)
    a = ReadAvgFile(deblank(filemat_theta2(index1,:)));
    ref = avg_ref_add_contingent(a);
    SaveAvgFile(deblank(filemat_theta2(index1,:)), ref);
end

% convolve them with a Gaussian kernel and save as .conv.at

shape = pdf('norm', -0:400, 200, 100); 

for index1 = 1: size(filemat_theta1, 1)
    a = ReadAvgFile(deblank(filemat_theta1(index1,:)));
  for chan = 1:129
   b(chan,:) = conv(a(chan,:), shape, 'same');
  end
    SaveAvgFile(deblank(filemat_theta1(index1,:)), b);
end

for index1 = 1: size(filemat_theta2, 1)
    a = ReadAvgFile(deblank(filemat_theta2(index1,:)));
     for chan = 1:129
   b(chan,:) = conv(a(chan,:), shape, 'same');
      end
    SaveAvgFile(deblank(filemat_theta2(index1,:)), b);
end


[topo_tmat, mat3d_1, mat3d_2] = topottest(filemat_theta1, filemat_theta2, [], 'testtheta.at');

%%
data3d = cat(1, mat3d_1, mat3d_2);
meandata = z_norm(squeeze(mean(data3d,3)));
labels = [ones(129,1); ones(129,1).*2];

for subject = 1:29
    for timex = 1:size(meandata,2)
        VMdl = fitclinear(squeeze(data3d(:,timex, subject))',labels,'ObservationsIn','columns','KFold',5,...
        'Learner','logistic','Solver','sparsa','Regularization','lasso');
        ce(subject, timex) = kfoldLoss(VMdl);
        if timex/100 == round(timex/100), fprintf('.'), end
    end
end


