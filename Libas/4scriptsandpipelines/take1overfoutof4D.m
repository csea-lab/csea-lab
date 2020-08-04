% takes 4 D files from Kierstin's Bop and removes 1/f from each time point

filemat = getfilesindir(pwd, '*.pow4.mat')

for file = 1:size(filemat,1)
    
    WaPower4d = []; 
    
    a = load(deblank(filemat(file,:))); 
    
    mat4d = a.WaPower4d; clear a
    
    for sensor = 1:size(mat4d,1)       
        
          for trial =  1:size(mat4d,4)
              
                meanspec = squeeze(mean(mat4d(sensor, :, :, trial), 2)); 
                [beta] = polyfit(1:length(meanspec),meanspec',2);       
                [expmod] = abs(polyval(beta, 1:length(meanspec)));
              
                for time  = 1:size(mat4d,2)
                   
                    WaPower4d(sensor, time, :, trial) = squeeze(mat4d(sensor, time, :, trial))./expmod';
                    
                end % time
            
          end% trial
             
    end% sensor
    
    eval(['save ' deblank(filemat(file,:)) '.1oFout.mat WaPower4d -mat']); 
    
    fprintf('.')
       
end % file

