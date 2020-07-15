function [ mat3d ] = set2mat( filemat )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

for index = 1:size(filemat, 1); 
    
    a = pop_loadset(deblank(filemat(index,:))); 
    
    mat3d = a.data; 
    
    eval(['save ' deblank(filemat(index,:)) '.mat mat3d -mat'])
    
   size(mat3d,3)
    
    
end

