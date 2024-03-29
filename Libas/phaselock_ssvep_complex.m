% read_edith_ERP.m
% reads exported file from edith
% puts it in 3d format, calculates phase and phaselocking time series for
% targetfreq over time, relative to Fcz
function [PLV_Oz, tempPLV_Oz] = phaselock_ssvep_complex(filemat, targetfreq, timerange); 


for fileindex = 1: size(filemat,1); % loop over files
    
   % generate 3d object from appfile
   [Data,Version,LHeader,ScaleBins,NChan,NPoints,NTrials,SampRate,AvgRefStatus,File,Path,FilePath,EegMegStatus,NChanExtra,AppFileFormatVal]=...
	ReadAppData(deblank(filemat(fileindex,:))); 

      outmat = zeros(NTrials, NChan, NPoints); 
      
     
    for trial = 1 : NTrials; 

        outmat(trial,:,:) = ReadAppData(deblank(filemat(fileindex,:)),trial);
    end
   
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
   % from here: phase an phase-locking
   
    taxis = 0:1000/SampRate:NPoints*1000/SampRate - 1000/SampRate;
	taxis = taxis/1000; 
    
	M2 = 40;
    
	squarecos1 = (cos(pi/2:(pi-pi/2)/M2:pi-(pi-pi/2)/M2)).^2;
	
	squarecosfunction = [squarecos1 ones(1,length(taxis)-length(squarecos1).*2) fliplr(squarecos1)];
	
	size(squarecosfunction)
	
    %[B, A] = butter(3, 0.008);
    
	[B, A] = butter(3, 0.015);  % real filter for faces and IAPS
	tempPLV_Oz = [];
    tic 
	for trial = 1:NTrials; 
        
        for channel = 1:NChan

            Xsin(trial,channel,:) = squeeze(outmat(trial, channel,:))' .* squarecosfunction .* sin(targetfreq .*2 *pi * taxis);
            Xcos(trial,channel,:) = squeeze(outmat(trial, channel,:))' .* squarecosfunction .* cos(targetfreq .*2 *pi * taxis);

            XsinF(trial,channel,:) = filtfilt(B,A,Xsin(trial,channel,:)); 
            XcosF(trial,channel,:) = filtfilt(B,A,Xcos(trial,channel,:)); 
                      

        end % channels

    end % trials
    
            demodmat = 2 * sqrt(XsinF .^2 + XcosF .^2);
            
            demodmat = squeeze(mean(demodmat,1));
   
            phasematcomplex = complex(XsinF, XcosF) ./abs(complex(XsinF, XcosF));
            
            for chan = 1:NChan, tempPLV_Oz(:,chan,:) = (phasematcomplex(:,chan,:) + phasematcomplex(:,75,:))./2; end % 75 is Oz
        
            %PLV_Oz =
            %squeeze(abs(sum(sum(tempPLV_Oz(:,:,timerange),1),3)))./(NTrials * length(timerange));
            % for permutation: 
            
            PLV_Oz = squeeze(abs(sum(sum(tempPLV_Oz(:,:,[timerange],1),3))))./(NTrials * length(timerange));
            
            % make sure it is a column vector
            if size(PLV_Oz,1) == 1, PLV_Oz = PLV_Oz'; end
            
            PLV_Oz(75) = 1; figure(1); plot(PLV_Oz); 
            
            [File,Path,FilePath]=SaveAvgFile([deblank(filemat(fileindex,:)) '.plv'],PLV_Oz,[],[], SampRate);        
            
            toc
   
end
   