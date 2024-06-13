%LIOR_RESS

RESS_time = []; 

plotflag = 1

SampRate  = 512;

elcs = 1:64; % electrodes to include

Targetfreq = 10; 

timewin = 1025:3584; 

outmat = data10{1,2}; 

% filter 3d
        signal3d = filterFGx(outmat,SampRate,Targetfreq,.2);
        
        referenceUP3d = filterFGx(outmat,SampRate,Targetfreq+1,1);

        referenceLO3d = filterFGx(outmat,SampRate,Targetfreq-1,1);

         % reshape, time, and baseline
            signal = reshape(signal3d(:, timewin, :), size(outmat,1), []); 
            signal = bsxfun(@minus,signal,mean(signal,2));

            referenceUP = reshape(referenceUP3d(:, timewin, :), size(outmat,1), []); 
            referenceUP = bsxfun(@minus,referenceUP,mean(referenceUP,2));

            referenceLO = reshape(referenceLO3d(:, timewin, :), size(outmat,1), []); 
            referenceLO = bsxfun(@minus,referenceLO,mean(referenceLO,2));

             % covariance   
            Sigcov = (signal * signal')./range(timewin);
            RefcovUP = (referenceUP * referenceUP')./range(timewin);
            RefcovLO = (referenceLO * referenceLO')./range(timewin);

            [W,L]=eig(Sigcov, (RefcovUP+RefcovLO)./2);
           % [W,L]=eig(Sigcov(elcs, elcs), RefcovUP(elcs, elcs));

            [~,comp2plot] = max(diag(L)); % find maximum component


        % reconstruct RESS component time series
        for trial = 1:size(outmat,3)
         RESS_time( :, trial) = W(:,comp2plot)'*squeeze(outmat(:,:, trial));
        end
        
        %below needs fixing
        %[powsing, freqsing] = FFT_spectrum3D(reshape(RESS_time(timewin,:), 1, size(signal3d, 2), size(signal3d, 3)), timewin, SampRate);
        
        [pow, phase, freqs] = FFT_spectrum(mean(RESS_time(timewin,:),2)', 512);
        
        SaveAvgFile('spatfilt.atg',W(:,comp2plot))

        
        if plotflag, figure(99)
            
        subplot(2,1,1), plot(squeeze(mean(RESS_time, 2)))
        subplot(2,1,2), plot(freqs(5:120), pow(1, 5:120)); pause(1)
        end




    
    
