%% for voxel patterns form ROIs% first get data 
clear
cd '/Users/andreaskeil/Desktop/rsa_files'
filemat = getfilesindir(pwd, '*Amy*R.*'); % get a list of the files

% now read in the voxelwise BOLD betas, the come in voxel by condition
% matrices

array4decoding = []; 

for fileindex = 1:size(filemat, 1)

    temp = readtable(deblank(filemat(fileindex,:)));
    temp2 = table2array(temp);

    array4decoding = cat(3, array4decoding, temp2); 

end

%%

for condition1 = 1:4
    for condition2 = 1:4
        y = zeros(size(filemat, 1).*2, 1); % empty label vector
        y(1:size(filemat, 1)) = condition1; 
        y(size(filemat, 1)+1:end) = condition2; % labels

        X1 = squeeze(array4decoding(:, condition1, :)); 
        X2 = squeeze(array4decoding(:, condition2, :)); 
        X = cat(2, X1, X2); 

        svmModel = fitclinear(X', y, 'KFold',5,...
    'Learner','logistic','Solver','sparsa','Regularization','lasso');
      kfoldLoss(svmModel)
         accuracy(condition1, condition2) = [1 - kfoldLoss(svmModel)];
    end
end

imagesc(accuracy)
accuracy


