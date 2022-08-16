% get RDM matrix for generalization learning data
%
filemat = getfilesindir(pwd, '*.ar')
[demodmat, phasemat]=steadyHilbert(filemat, 15, 200:418, 14, 0, []);
%%
% create filemats if needed
filemat = getfilesindir(pwd, '*15');
for x = 1:14
    filemat_hamp{x} = filemat(x:14:end,:)
end

%% make a 4-d array
for condition = 1:14
    actmat = filemat_hamp{condition};
 for subject = 1:size(actmat,1)   
    mat4d(:, :, subject, condition) = ReadAvgFile(deblank(actmat(subject,:))); 
 end
end

%% make a 3-d array for a given window and run RDM code
window = 500:1500;
mat3d_early = squeeze(mean(mat4d(:, window,: , :), 2)); 
%mat3d_early = squeeze(mean(mat4d(:, window,: , 8:14), 2)); 
RDMmat = zeros(29, 7, 7); 
for participant = 1:29
    for index1 = 1:7
        for index2 = 1:7
         temp = corrcoef(squeeze(mat3d_early(:, participant, index1)), squeeze(mat3d_early(:, participant, index2))); 
        RDMmat(participant, index1, index2) = temp(1,2); 
        end
    end
end
%% plot the data by subject
RDMmat(RDMmat ==1) = nan; 

figure
for participant = 1:29
    
    imagesc(squeeze(RDMmat(participant, :,:))), title(num2str(participant)), pause
    
end

figure
imagesc(squeeze(mean(RDMmat))), colorbar, title('grand mean')
%% for the grand mean
RDMGM = []; 
window = 980:1020; 
mat3dGM = []; 

filemat = getfilesindir(pwd, 'GM*.at*');
filemat = filemat(3:2:end,:);
atmat = filemat([1 7:14 2:6], :);

    for x = 1:14
        a = ReadAvgFile(deblank(atmat(x,:))); 
        mat3dGM(:, :, x) = a; 
    end 
    
    mat3dGM = squeeze(mean(mat3dGM(:, window, :), 2)); 

    for index1 = 1:7
        for index2 = 1:7
         temp = corrcoef(squeeze(mat3dGM(:, index1)), squeeze(mat3dGM(:, index2))); 
        RDMGM(index1, index2) = temp(1,2); 
        end
    end
    RDMGM(RDMGM >.99 ) = nan; 
    imagesc(RDMGM), colorbar, title('from grand mean')