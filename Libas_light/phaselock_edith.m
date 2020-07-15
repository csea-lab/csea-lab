% read_edith_ERP.m
% reads exported file from edith
% puts it in 3d format, calculates phase and phaselocking time series for
% targetfreq over time, relative to Fcz
function [PLV_FCz, demodmat] = phaselock_edith(filemat, targetfreq); 

SampRate = 512; 

for fileindex = 1: size(filemat,1); % loop over files
    
    line = 1; 
    
    outmat =[];
    tempPLV_FCz = []; 
    
    fid = fopen(deblank(filemat(fileindex,:))); 
    
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
       
       size(str2num(line)')
     
       outmat = [outmat str2num(line)'];
       
       size(outmat)
     
        line = fgetl(fid);
       
   end
   fclose('all')
   
   outmat = reshape(outmat', [n_channels n_trials  n_samples]);
   outmat = permute(outmat, [2 1 3]); 
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
   % from here: phase an phase-locking
   
    taxis = 0:1000/SampRate:n_samples*1000/SampRate - 1000/SampRate;
	taxis = taxis/1000; 
    
	M2 = 40;
	squarecos1 = (cos(pi/2:(pi-pi/2)/M2:pi-(pi-pi/2)/M2)).^2;
	
	squarecosfunction = [squarecos1 ones(1,length(taxis)-length(squarecos1).*2) fliplr(squarecos1)];
	
	size(squarecosfunction)
	
    %[B, A] = butter(3, 0.008);
    
	[B, A] = butter(3, 0.008);  % real filter for faces and IAPS
	
	for trial = 1:n_trials; 
        
        for channel = 1:n_channels

            Xsin(trial,channel,:) = squeeze(outmat(trial, channel,:))' .* squarecosfunction .* sin(targetfreq .*2 *pi * taxis);
            Xcos(trial,channel,:) = squeeze(outmat(trial, channel,:))' .* squarecosfunction .* cos(targetfreq .*2 *pi * taxis);

            XsinF(trial,channel,:) = filtfilt(B,A,Xsin(trial,channel,:)); 
            XcosF(trial,channel,:) = filtfilt(B,A,Xcos(trial,channel,:)); 
            
           
                       

        end % channels

    end % trials
    
            demodmat = 2 * sqrt(XsinF .^2 + XcosF .^2);
            
            demodmat = squeeze(mean(demodmat,1));
   
            phasematcomplex = complex(XsinF, XcosF) ./abs(complex(XsinF, XcosF));
            
            size(phasematcomplex)
            
            for chan = 1:n_channels, tempPLV_FCz(:,chan,:) = (phasematcomplex(:,chan,:) + phasematcomplex(:,11,:))./2;end % 11 is FCz
            
            PLV_FCz = squeeze(abs(sum(tempPLV_FCz,1)))./n_trials;
             
            PLV_FCz(11,:) = ones(1,n_samples); 
           
            save([deblank(filemat(fileindex,:)) '.plv'], 'PLV_FCz', '-ascii')
            
            save([deblank(filemat(fileindex,:)) '.indamp'], 'demodmat', '-ascii')
   
end
    
    