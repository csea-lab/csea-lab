% code for resampling/simulating for konio
clear
filemat = getfilesindir(pwd); 
filemat1 = filemat(1:4:end,:); 

mat4d_1 = []; 

for index = 1: size(filemat1,1)
    tmp = load(deblank(filemat1(index,:)));  
    mat4d_1 = cat(3, mat4d_1, tmp.Mat3D);
end

%%
filemat = getfilesindir(pwd); 
filemat2 = filemat(2:4:end,:); 
mat4d_2 = []; 

for index = 1: size(filemat2,1)
    tmp = load(deblank(filemat2(index,:)));  
    mat4d_2 = cat(3, mat4d_2, tmp.Mat3D);
end

%%
filemat = getfilesindir(pwd); 
filemat3 = filemat(3:4:end,:); 
mat4d_3 = []; 

for index = 1: size(filemat3,1)
    tmp = load(deblank(filemat3(index,:)));  
    mat4d_3 = cat(3, mat4d_3, tmp.Mat3D);
end

%%
filemat = getfilesindir(pwd); 
filemat4 = filemat(4:4:end,:); 
mat4d_4 = []; 

for index = 1: size(filemat4,1)
    tmp = load(deblank(filemat4(index,:)));  
    mat4d_4 = cat(3, mat4d_4, tmp.Mat3D);
end

%% now make fake subjects
% condition1
for simsub = 1:50
       bootstrapvec = randi(size(mat4d_1,3), 1,28)';
       submean = squeeze(mean(mat4d_1(:, :, bootstrapvec), 3)); 
       size(submean)
       SaveAvgFile(['PseudoSub' num2str(simsub) '.at1.ar'], submean,[],[], 500,[],[],[],[],301)
end

% condition2
for simsub = 1:50
       bootstrapvec = randi(size(mat4d_2,3), 1,28)';
       submean = squeeze(mean(mat4d_2(:, :, bootstrapvec), 3)); 
       size(submean)
       SaveAvgFile(['PseudoSub' num2str(simsub) '.at2.ar'], submean,[],[], 500,[],[],[],[],301)
end

% condition3
for simsub = 1:50
       bootstrapvec = randi(size(mat4d_3,3), 1,28)';
       submean = squeeze(mean(mat4d_3(:, :, bootstrapvec), 3)); 
       size(submean)
       SaveAvgFile(['PseudoSub' num2str(simsub) '.at3.ar'], submean,[],[], 500,[],[],[],[],301)
end

% condition4
for simsub = 1:50
       bootstrapvec = randi(size(mat4d_4,3), 1,28)';
       submean = squeeze(mean(mat4d_4(:, :, bootstrapvec), 3)); 
       size(submean)
       SaveAvgFile(['PseudoSub' num2str(simsub) '.at4.ar'], submean,[],[], 500,[],[],[],[],301)
end





