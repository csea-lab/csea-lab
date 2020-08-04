

for fileindex = 1:size(filemat1,1)  % here filemat1 is .ig files
    
    name = deblank(filemat1(fileindex,:)); 

           fid = fopen(name);
           forgetit =  fgetl(fid); 
           IGindices = str2num(fgetl(fid)); 
           
           IGindices(IGindices>120) = [] 
                    
           % now load the corresponding .dat file and find the accuracy
           % for the first and second stimulus, then make quintiles
           %ONLY for the trials that are also in the EEG. 
           
           % first: angles 1 (the deviance of the first report) 
           
             [anglediff2] = getcon_wmjess(filemat2(fileindex,:)); 

            angles1 = anglediff2(IGindices, 1); 
        
            quantiles = quantile(angles1,4);
            
            % these following are indices into only the subset of the EEG trials 
            indexmat{1} = find(angles1 <= quantiles(1)); 
            indexmat{2} = find(angles1 > quantiles(1) & angles1 <= quantiles(2)); 
            indexmat{3} = find(angles1 > quantiles(2) & angles1 <= quantiles(3));
            indexmat{4} = find(angles1 > quantiles(3) & angles1 <= quantiles(4)); 
            indexmat{5} = find(angles1 > quantiles(4)); 
            
            
             [outmat_small] = app2mat(filemat_app(fileindex,:), 0); 

              % outmat_small = outmat(:, :, :);  

                for y = 1:5

                [WaPower, PLI, PLIdiff] = wavelet_app_mat(outmat_small(:, :, indexmat{y}), 1000, 10, 70, 4, [], ['stim1' num2str(y) '.mat']); 
                
                end
                
      % second: do the same for the second report
                
            [anglediff2] = getcon_wmjess(filemat2(fileindex,:)); 

            angles2 = anglediff2(IGindices, 2); 
        
            quantiles = quantile(angles2,4);
            
            % these following are indices into only the subset of the EEG trials 
            indexmat{1} = find(angles2 <= quantiles(1)); 
            indexmat{2} = find(angles2 > quantiles(1) & angles2 <= quantiles(2)); 
            indexmat{3} = find(angles2 > quantiles(2) & angles2 <= quantiles(3));
            indexmat{4} = find(angles2 > quantiles(3) & angles2 <= quantiles(4)); 
            indexmat{5} = find(angles2 > quantiles(4)); 
    
                for y = 1:5

                [WaPower, PLI, PLIdiff] = wavelet_app_mat(outmat_small(:, :, indexmat{y}), 1000, 10, 70, 4, [], ['stim2' num2str(y) '.mat']); 
                
                end
                                 
            
end % loop over files