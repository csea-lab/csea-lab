function  [powsub, freqs] = RESSquintiles_jess(filematig, filemat_dat, filemat_ressmat, timewin, SampRate)

          %divides the data (after RESS analysis) into quintiles based on
          %behavioral data
          plotflag = 1; 
         
for fileindex = 1:size(filematig,1) 
    
    name = deblank(filematig(fileindex,:)); 
    
    nameid = filematig(fileindex,1:7);

           fid = fopen(name);
           forgetit =  fgetl(fid); 
           IGindices = str2num(fgetl(fid)); 
           
           IGindices(IGindices>120) = [] 
                    
           % now load the corresponding .dat file and find the accuracy
           % for the first and second stimulus, then make quintiles
           %ONLY for the trials that are also in the EEG. 
          
           
            [anglediff2] = getcon_wmjess(filemat_dat(fileindex,:)); 

            angles1 = anglediff2(IGindices, 2); %angles1 is the deviance of the report given by the participant
            
            quantiles = quantile(angles1,4);
            
            %makes the quintiles 
            indexmat{1} = find(angles1 <= quantiles(1)); 
            indexmat{2} = find(angles1 > quantiles(1) & angles1 <= quantiles(2)); 
            indexmat{3} = find(angles1 > quantiles(2) & angles1 <= quantiles(3));
            indexmat{4} = find(angles1 > quantiles(3) & angles1 <= quantiles(4)); 
            indexmat{5} = find(angles1 > quantiles(4)); 
            
            [outmat] = load(deblank(filemat_ressmat(fileindex,:)), '-mat'); 
            
            allressdata = outmat.RESS_time; 
            
            for y = 1:5; 
                
                [subdata_ress] = allressdata(:, (indexmat{y})');
                [powsub(y,:), freqs] = FFT_spectrum3D(reshape(subdata_ress, 1, size(subdata_ress, 1), size(subdata_ress, 2)), timewin, SampRate);
                if plotflag
                    subplot(5,1,y), plot(freqs(1:40), powsub(y, 1:40)), hold on
                end
                
            end
hold off

end
    