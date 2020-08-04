featurevec = 1:2

trainlabels = [ones(253,1); zeros(253,1)]; 

for x = 1:200 
    
    
    temp0 = randperm(273); indexvec0 = temp0(1:253) ; indexvec0b = temp0(254:273); 
    temp1 = randperm(273); indexvec1 = temp1(1:253) ; indexvec1b = temp1(254:273); 
    
    
    data_1 = score_z(1:273,:); data_0 = score_z(274:end,:); 
    % 2. apply to the data and run svmtrain
    
    datatrain = [data_0(indexvec0, featurevec); data_1(indexvec1,featurevec)];
    
    SVMSTRUCT = svmtrain(datatrain(:,  featurevec), trainlabels, 'kernel_function', 'linear',  'options', strucout, 'showplot', 'true'); 
    
    % .3 run svmclassify on the remaining data
    
    
    datatest = [data_0(indexvec0b, featurevec); data_1(indexvec1b,featurevec )];
    
    GROUP = svmclassify(SVMSTRUCT, datatest); 
    
    corr1(x) = sum(GROUP(1:20)==1)./20;
    corr0(x) = sum(GROUP(21:40)==0)./20;   
    
end