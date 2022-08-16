function [combmat] = combineLP_alon(filemat1,filemat2)

for index = 1:size(filemat1,1)
    
    filename1 = deblank(filemat1(index,:)); 
    filename2 = deblank(filemat2(index,:)); 

    a1 = load(filename1); 
    a2 = load(filename2); 
    
    mat1 = a1.data3d; 
    mat2 = a2.data3d;
    
    combmat = cat(3, mat1, mat2); 
    
    eval(['save ' filename1(1:end-10) '.comb.mat combmat'])
    
end