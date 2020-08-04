% read_edith_ERP.m
% reads exported file from edith
function [outmat] = read_edith_ERP(filemat); 



for fileindex = 1: size(filemat,1); 
    
    line = []; 
    
    outmat =[];
    
    fid = fopen(filemat(fileindex,:)); 
    
    electrodes = fgetl(fid)
    
   line = fgetl(fid)
   
   while line ~= -1
       
       outmat = [outmat str2num(line)']; 
       
        line = fgetl(fid);
       
   end
   
   
end
    
    