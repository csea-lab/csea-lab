function  [outmat] = RESS_regress(filematig, filemat_dat, filemat_ressmat857Hz,filemat_ressmat6Hz, baseline, timewin, SampRate, plotflag)

          %divides the data (after RESS analysis) into quintiles based on
          %behavioral data
          plotflag = 1; 
          
          outmat = []; 
         
for fileindex = 1:size(filematig,1) 
   
    powbsl = []; 
    bslpow8 = [];
    bslpow6 = []; 
    powsub8 = []; 
    powsub6 =[]; 
    snrsub8 = []; 
    snrsub6 = [];
    powmov6 = []; 
    powmov8 = []; 
    
    name = deblank(filematig(fileindex,:)); 
    
    nameid = filematig(fileindex,1:7);

           fid = fopen(name);
           forgetit =  fgetl(fid); 
           IGindices = str2num(fgetl(fid)); 
           
           IGindices(IGindices>120) = [];
           
           subjectvariable = ones(length(IGindices), 1).* fileindex; 
                    
           % now load the corresponding .dat file and find the accuracy
           % for the first and second stimulus, then make quintiles
           %ONLY for the trials that are also in the EEG. 
                    
           [anglediff2] = getcon_wmjess(filemat_dat(fileindex,:)); 

            angles1 = anglediff2(IGindices, 1); %location 1
            angles2 = anglediff2(IGindices, 2); %location 2
            
           % diffangles12 = angles1 - angles2; %difference between angular differences 
           
            %read in RESS files for each frequency
            [outmat857Hz] = load(deblank(filemat_ressmat857Hz(fileindex,:)), '-mat'); 
            [outmat6Hz] = load(deblank(filemat_ressmat6Hz(fileindex,:)), '-mat');
            
            allressdata857Hz = outmat857Hz.RESS_time; 
            allressdata6Hz = outmat6Hz.RESS_time;
                                      
                %FFT for 8.57Hz 
                for trial = 1:length(IGindices)
                [tempspec8] = FFT_spectrum(allressdata857Hz(timewin, trial) , SampRate);
                tempbsl8 = FFT_spectrum(allressdata857Hz(1:600, trial) , SampRate);
                powsub8(trial) = tempspec8(21); 
                powbsl8(trial) = mean(tempbsl8(7:8)); 
                [powmov8(trial), snrsub8(trial)] = steadvec2singtrial(allressdata857Hz(:, trial)', 0, baseline, timewin(1:end-20), 8.57, 600, SampRate);
                end
                 
                %FFT for 6Hz 
                for trial = 1:length(IGindices)
                [tempspec6] = FFT_spectrum(allressdata6Hz(timewin, trial) , SampRate);
                tempbsl6 = FFT_spectrum(allressdata6Hz(1:600, trial) , SampRate);
                powsub6(trial) = tempspec6(15); 
                powbsl6(trial) = mean(tempbsl6(7:8)); 
                [powmov6(trial), snrsub6(trial)] = steadvec2singtrial(allressdata6Hz(:, trial)', 0, baseline, timewin(1:end-20), 6 , 600, SampRate);
                end
                
                powbsl = (powbsl8 + powbsl6)./2; 
                
                outmat = [outmat; [subjectvariable powsub6' powsub8' powmov8' powmov6' snrsub6' snrsub8' powbsl' angles1 angles2]];
            
               % scatter(snrsub8, angles2), lsline, pause
      
        %  eval([' save  ' nameid 'diffquintilesSNR.pow.mat SNRdiff -mat']); 
  
end

fclose('all')
    