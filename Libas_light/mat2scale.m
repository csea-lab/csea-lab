function [outmat] = mat2scale(filemat, filtervec)

for index = 1:size(filemat,1), 
    
    a = load(deblank(filemat(index,:))); 
    
    tempmat = a.dataout; 
    mulmat = repmat(filtervec, [1, size(tempmat,2), size(tempmat,3)]);
    
    outmat = tempmat.*mulmat; 
    
    eval(['save ' deblank(filemat(index,:)) '.MNErad.mat outmat'])
    
end
