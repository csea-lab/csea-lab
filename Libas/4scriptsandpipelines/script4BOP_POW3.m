% script4BOP_POW3

freq = 9; 
Mat4Ftest = []; 

filemat_1 = getfilesindir(pwd,  '*1001.pow3.mat')
filemat_2 = getfilesindir(pwd,  '*1002.pow3.mat')
filemat_3 = getfilesindir(pwd,  '*2001.pow3.mat')
filemat_4 = getfilesindir(pwd,  '*2002.pow3.mat')

% and so on 

for subject = 1: 20 

    % for each subject, put together the 4 "conditions" into one matrix, 
    % then stack the matrices
    pow3_1 = load(filemat_1(subject,:)); 
    pow_1 = pow3_1.WaPower(:, :, freq); 
    
    pow3_2 = load(filemat_2(subject,:)); 
    pow_2 = pow3_2.WaPower(:, :, freq); 
    
    pow3_3 = load(filemat_3(subject,:)); 
    pow_3 = pow3_3.WaPower(:, :, freq); 
    
    pow3_4 = load(filemat_4(subject,:)); 
    pow_4 = pow3_4.WaPower(:, :, freq); 
    
    Mat_temp= cat(3, pow_1, pow_2, pow_3, pow_4); 
    
    Mat4Ftest = cat(4, Mat4Ftest, Mat_temp); 
    
end

% surpise ! 

%no and 1 versus both 
repeatmat = permute(Mat4Ftest, [1 4 3 2]); 

for time = 1:size(repeatmat, 4)
[Fcontmat(:, time),rcontmat(:, time),MScont,MScs, dfcs]=contrast_rep(squeeze(repeatmat(:, :, :, time)),[-.5 -1 1 .5]); 
if time/100 == round(time./100), fprintf('.'), end
end




