%ttest3d
    function [outmat, mat4d1, mat4d2] = ttest3d(filemat1, filemat2, downsamp, bslvec)

if nargin < 3, downsamp = 1; end

structest = load(deblank(filemat1(1,:))); %to know the size

mat4d1 = zeros(size(structest.powbsl, 1), size(structest.powbsl, 2), size(structest.powbsl, 3), size(filemat1,1));
mat4d2 = zeros(size(structest.powbsl, 1), size(structest.powbsl, 2), size(structest.powbsl, 3), size(filemat1, 1));


for x = 1:size(filemat1,1)
    
    struc1 = load(deblank(filemat1(x,:)));
    
    struc2 = load(deblank(filemat2(x,:))); 
    
    if isempty(bslvec)
          mat4d1(:, :, :, x) = struc1.powbsl; 
          mat4d2(:, :, :, x) = struc2.powbsl; 
    else
         mat4d1(:, :, :, x) = bslcorrWAMat_div(struc1.powbsl, bslvec); 
         mat4d2(:, :, :, x) = bslcorrWAMat_div(struc2.powbsl, bslvec); 
    end
   
   fprintf('.')
    
end

disp('end building matrix, now downsampling if downsamp >1') 

mat4d1 = mat4d1(:, 1:downsamp:end, :, :); 

mat4d2 = mat4d2(:, 1:downsamp:end, :, :); 

disp('done downsampling, calculating ttests') 


[dummy, dummy, dummy, stats] = ttest(mat4d1, mat4d2, [], [], 4); 

outmat = stats.tstat; 
