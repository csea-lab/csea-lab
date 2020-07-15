% read_edith_ERP.m
% reads exported file from edith
function [outmat] = read_edith_trials(filemat); 



for fileindex = 1: size(filemat,1); 
    
    line = 1; 
    
    outmat =[];
    
    fid = fopen(filemat(fileindex,:)); 
    
    values = fgetl(fid);
    value_vec = str2num(values);
    
    n_channels =  value_vec(1)
    n_samples = value_vec(2)
    n_trials = value_vec(3)
    
    condition  = fgetl(fid);
    trial_window = fgetl(fid);
    bslwindow = fgetl(fid);
    trials = fgetl(fid);
    channelvec = fgetl(fid);
   
   line = fgetl(fid)
   
   while line ~= -1
     
       outmat = [outmat str2num(line)'];
     
        line = fgetl(fid);
       
   end
   fclose('all')
   
   outmat = reshape(outmat', [n_channels n_trials  n_samples]);
   outmat = permute(outmat, [2 1 3]); 
   
end
    
    