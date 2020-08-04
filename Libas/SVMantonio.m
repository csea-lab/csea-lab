
% uses workspace from antonio

featurevec = 2:2:18

data_1 = allfeatures(accvec==1,:);
data_0 = allfeatures(accvec==0,:);

trainlabels= zeros(450, 1);  % 450 of the trials are training trials
trainlabels(226:end) = 1; % top half is taken from 0 scond from 1

clear corr0, clear corr1

for x = 1:100 
   
    % generate training data
    
    % 1. find 225 random numbers between 1 and 275 (length of data_1 and
    % data_0) 
    
    temp0 = randperm(275); indexvec0 = temp0(1:225) ; 
    temp1 = randperm(275); indexvec1 = temp1(1:225) ; 
    
    % 2. apply to the data and run svmtrain
    
    datatrain = [data_0(indexvec0, featurevec); data_1(indexvec1,featurevec)];
    
    SVMSTRUCT = svmtrain(datatrain(:,  :), trainlabels, 'kernel_function', 'rbf'); 
    
    % .3 run svmclassify on the remaining data
    
    indexvec0_test = temp0(226:end) ; 
    indexvec1_test = temp1(226:end) ; 
    
    datatest = [data_0(indexvec0_test, featurevec); data_1(indexvec1_test,featurevec )];
    
    GROUP = svmclassify(SVMSTRUCT, datatest); 
    
    corr0(x) = sum(GROUP(1:50)==0)./50;
    corr1(x) = sum(GROUP(51:100)==1)./50;   
    
end