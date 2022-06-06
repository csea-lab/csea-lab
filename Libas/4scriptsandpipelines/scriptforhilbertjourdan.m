
filemat = getfilesindir(pwd, '*.ar')
[demodmat, phasemat]=steadyHilbert(filemat, 15, 200:418, 14, 0, []);
%%
% create filemats if needed
filemat = getfilesindir(pwd, '*15');
for x = 1:14
    filemat_hamp{x} = filemat(x:14:end,:)
end
%%%%
%mergemulticons(filemat, 14, 'GMhamp15')
%% 
% make a 4-d array
for condition = 1:14
    actmat = filemat_hamp{condition};
 for subject = 1:size(actmat,1)   
    mat4d(:, :, subject, condition) = ReadAvgFile(deblank(actmat(subject,:))); 
 end
end
%%
%%%% generalization, not overgeneralization
% early
for time = 1:1501
[Fcontmat(:,time, :),rcontmat,MScont,MScs, dfcs]=contrast_rep(squeeze(mat4d(:, time, :, 1:7)),[-1.0 -0.5 0.5 2.0 0.5 -0.5 -1]); 
end
SaveAvgFile('F_earlyGen.atg',Fcontmat,[],[], 500,[],[],[],[],419);
% late
for time = 1:1501
[Fcontmat(:,time, :),rcontmat,MScont,MScs, dfcs]=contrast_rep(squeeze(mat4d(:, time, :, 8:14)),[-1.0 -0.5 0.5 2.0 0.5 -0.5 -1]); 
end
SaveAvgFile('F_lateGen.atg',Fcontmat,[],[], 500,[],[],[],[],419);
%%
%%%% overgeneralization
% early
for time = 1:1501
[Fcontmat(:,time, :),rcontmat,MScont,MScs, dfcs]=contrast_rep(squeeze(mat4d(:, time, :, 1:7)),[-3.0 0.5 1.5 2.0 1.5 0.5 -3]); 
end
SaveAvgFile('F_earlyOverGen.atg',Fcontmat,[],[], 500,[],[],[],[],419);
% late
for time = 1:1501
[Fcontmat(:,time, :),rcontmat,MScont,MScs, dfcs]=contrast_rep(squeeze(mat4d(:, time, :, 8:14)),[-3.0 0.5 1.5 2.0 1.5 0.5 -3]); 
end
SaveAvgFile('F_lateOverGen.atg',Fcontmat,[],[], 500,[],[],[],[],419);
%%
%%% lateral inhibition
% early
for time = 1:1501
[Fcontmat(:,time, :),rcontmat,MScont,MScs, dfcs]=contrast_rep(squeeze(mat4d(:, time, :, 1:7)),[0.5 -1.0 -2.0 5.0 -2.0 -1.0 0.5]); 
end
SaveAvgFile('F_earlyLatInh.atg',Fcontmat,[],[], 500,[],[],[],[],419);
% late
for time = 1:1501
[Fcontmat(:,time, :),rcontmat,MScont,MScs, dfcs]=contrast_rep(squeeze(mat4d(:, time, :, 8:14)),[0.5 -1.0 -2.0 5.0 -2.0 -1.0 0.5]); 
end
SaveAvgFile('F_lateLatInh.atg',Fcontmat,[],[], 500,[],[],[],[],419);

%%
a = ReadAvgFile('GMhamp15.at8');
tuningearly(:,1) = mean(a(:, 514:750),2);
a = ReadAvgFile('GMhamp15.at9');
tuningearly(:,2) = mean(a(:, 514:750),2);
a = ReadAvgFile('GMhamp15.at10');
tuningearly(:,3) = mean(a(:, 514:750),2);
a = ReadAvgFile('GMhamp15.at11');
tuningearly(:,4) = mean(a(:, 514:750),2);
a = ReadAvgFile('GMhamp15.at12');
tuningearly(:,5) = mean(a(:, 514:750),2);
a = ReadAvgFile('GMhamp15.at13');
tuningearly(:,6) = mean(a(:, 514:750),2);
a = ReadAvgFile('GMhamp15.at14');
tuningearly(:,7) = mean(a(:, 514:750),2);
SaveAvgFile('tuningearly.atg', tuningearly)

for sens = 1:129, tuning_gener_innerproduct(sens) = tuningearly(sens,:) * [-1.0 -0.5 0.5 2.0 0.5 -0.5 -1]', end
tuning_gener_nnerproduct = tuning_gener_innerproduct';
SaveAvgFile('tuning_gener_innerproduct.atg', tuning_gener_innerproduct)

%%
% fit gaussian early time window using bootstrapping 
mat4dearly = squeeze(mean(mat4d(:, 519:750, :, :), 2));

% real data bootstrap
warning('off')
for sens = 1:129 
 for draw = 1:1000
     subjects = randi(size(mat4dearly,2),1,29);
        [betagauss, rgauss, mseearlytrials(sens, draw)] = Fitgaussian(squeeze(mean(mat4dearly(sens, subjects,1:7)))');
        gaussmean_earlytrials(sens, draw) = betagauss(1);
        gaussstd_earlytrials(sens, draw) = betagauss(2);
 end
    if sens./10 == round(sens./10), fprintf('.'), end
end
warning('on')
%% random permutation bootstrap and Bayes Factors
warning('off')
for sens = 1:129 
 for draw = 1:1000
     subjects = randi(size(mat4dearly,2),1,29);
        [betagauss, rgauss, mseearlytrials_perm(sens, draw)] = Fitgaussian(squeeze(mean(mat4dearly(sens, subjects,randperm(7))))');
        gaussmean_earlytrials_perm(sens, draw) = betagauss(1);
        gaussstd_earlytrials_perm(sens, draw) = betagauss(2);
 end
    if sens/10 == round(sens./10), fprintf('.'), end
end
warning('on')

for sens = 1:129 
    posteriorsigned_MSE(sens) = length(find(mseearlytrials(sens,:) < mseearlytrials_perm(sens,:))) ./ 1000;
    posteriorsigned_mean(sens) = length(find(gaussmean_earlytrials(sens,:) > gaussmean_earlytrials_perm(sens,:))) ./ 1000;
    posteriorsigned_std(sens) = length(find(gaussstd_earlytrials(sens,:) < gaussstd_earlytrials_perm(sens,:))) ./ 1000;
end

BF_MSE = posteriorsigned_MSE ./(1-posteriorsigned_MSE);
BF_mean = posteriorsigned_mean ./(1-posteriorsigned_mean);
BF_std = posteriorsigned_std ./(1-posteriorsigned_std);
%%
% fit gaussian late
for sens = 1:129 
    for subj = 1:29 
        [betagauss, rgauss, mselatetrials(sens, subj)] = Fitgaussian(squeeze(mat4dearly(sens, subj,8:14))');
         gaussmean_latetrials(sens, subj) = betagauss(1);
         gaussstd_latetrials(sens, subj) = betagauss(2);
    end
end


