%ttest3d
    function [critTmax, critTmin] = ttest3d_withperm(filemat1, filemat2, downsamp, bslvec)
    
    % this code does 3-d ttests but it permutes the filemat consiion
    % membership, to create permutation distributions and then detremines
    % the critical t-values

if nargin < 3, downsamp = 1; end

structest = load(deblank(filemat1(1,:))); %to know the size

mat4d1 = zeros(size(structest.WaPower, 1), size(structest.WaPower, 2), size(structest.WaPower, 3), size(filemat1, 1));
mat4d2 = zeros(size(structest.WaPower, 1), size(structest.WaPower, 2), size(structest.WaPower, 3), size(filemat1, 1));

for x = 1:size(filemat1,1)
        
    struc1 = load(deblank(filemat1(x,:)));
   
    if ~isempty(bslvec)
        struc1.WaPower = bslcorrWAMat_div(struc1.WaPower, bslvec);
    else
        struc1.WaPower = struc1.WaPower; 
    end
    
    struc2 = load(deblank(filemat2(x,:))); 
    
    if ~isempty(bslvec)
        struc2.WaPower = bslcorrWAMat_div(struc2.WaPower, bslvec);
    else
        struc2.WaPower = struc2.WaPower; 
    end
  
    
     mat4d1(:, :, :, x) = struc1.WaPower; 
     mat4d2(:, :, :, x) = struc2.WaPower; 
      
end


disp('end building matrix, now downsampling if downsamp >1') 

mat4d1_d = mat4d1(:, 1:downsamp:end, :, :); 

mat4d2_d = mat4d2(:, 1:downsamp:end, :, :); 

disp('done downsampling, calculating ttests') 


% draw loop
for draw = 1:800
    

    % flip the condition membership for random people
           
         mat4d1_draw = mat4d1_d; 
         mat4d2_draw = mat4d2_d; 
         
         %flip the coin
         coinvec = round(rand(size(filemat1,1), 1)); 
         
         for indexflip = 1:size(filemat1,1); 
             if coinvec(indexflip) == 1
                 mat4d1_draw(:, :, :, indexflip) = mat4d2_d(:, :, :, indexflip); 
                  mat4d2_draw(:, :, :, indexflip) = mat4d1_d(:, :, :, indexflip); 
             end
         end
         

        [dummy, dummy, dummy, stats] = ttest(mat4d1_draw, mat4d2_draw, [], [], 4); 

        outmat = stats.tstat; 

        [tvalvecmax] = mat2vec(squeeze(max(outmat)));
        [tvalvecmin] = mat2vec(squeeze(min(outmat)));

        tValvector_sort = sort([tvalvecmax tvalvecmin]);

        tmax_vec(draw) = tValvector_sort(floor(length(tValvector_sort).*0.95));
        tmin_vec(draw) = tValvector_sort(floor(length(tValvector_sort).*0.05));

        if draw/100 == round(draw/100), fprintf([num2str(draw) ' ']), end

end

thist = [tmax_vec tmin_vec];

hist(tmax_vec,100)
figure
hist(tmin_vec,100)
figure
hist(thist,100)

[bin,tval] = hist(thist,500);
critbin = sum(bin).*.975
cumbins = cumsum(bin);
indices = find(cumbins > critbin);
index = min(indices);
critTmax = tval(index)



[bin,tval] = hist(thist,500);
critbin = sum(bin).*0.025
cumbins = cumsum(bin);
indices = find(cumbins < critbin);
index = max(indices);
critTmin = tval(index)


