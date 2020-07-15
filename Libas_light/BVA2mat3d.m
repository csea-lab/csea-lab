function [mat3d] = BVA2mat3d(filemat,Nsensors,trialvector)
% this reads output from BVA and saves as 3-d matlab file
% inputs are a list of files and their respective trial counts

figure(99)

for x = 1:size(filemat,1)

    fid = fopen(deblank(filemat(x,:))); 
    
    b = fread(fid, [Nsensors, 900*trialvector(x)] , 'float32');
    
    mat3d = reshape(b, [Nsensors, 900, trialvector(x)]);
  
    ERP = mean(mat3d,3);
    plot(ERP'), pause(1)
    
    eval(['save ' deblank(filemat(x,:)) '.mat mat3d -mat']); 
    
    fclose(fid) ;
    
end


