%ttest3d
    function [outmat, mat4d1, mat4d2] = ttest3d(filemat1, filemat2, downsamp, bslvec)

if nargin < 3, downsamp = 1; end

structest = load(deblank(filemat1(1,:))); %to know the size

mat = eval(['structest.' char(fieldnames(structest))]);

mat4d1 = zeros(size(mat, 1), size(mat, 2), size(mat, 3), size(filemat1,1));
mat4d2 = zeros(size(mat, 1), size(mat, 2), size(mat, 3), size(filemat1, 1));


for x = 1:size(filemat1,1)
    
    struc1 = load(deblank(filemat1(x,:)));
    
    mat1 = eval(['struc1.' char(fieldnames(struc1))]);
    
    struc2 = load(deblank(filemat2(x,:))); 
    
    mat2 = eval(['struc2.' char(fieldnames(struc2))]);
    
    if isempty(bslvec)
          mat4d1(:, :, :, x) = mat1; 
          mat4d2(:, :, :, x) = mat2; 
    else
         mat4d1(:, :, :, x) = bslcorrWAMat_div(mat1, bslvec); 
         mat4d2(:, :, :, x) = bslcorrWAMat_div(mat2, bslvec); 
    end
   
   fprintf('.')
    
end

disp('end building matrix, now downsampling if downsamp >1') 

mat4d1 = mat4d1(:, 1:downsamp:end, :, :); 

mat4d2 = mat4d2(:, 1:downsamp:end, :, :); 

disp('done downsampling, calculating ttests') 


[dummy, dummy, dummy, stats] = ttest(mat4d1, mat4d2, [], [], 4); 

outmat = stats.tstat; 
