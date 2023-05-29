function [RESS_time] = RESS_mat(filemat, elcs, timewin, SampRate, Targetfreq, plotflag) 
% elcs  = electrodes to include (not toooooo many) 
% timewin = which sample points to include

fsamp4save = 1000./(SampRate./length(timewin));

for index = 1:size(filemat,1)
    
RESS_time = [];
        temp = load(deblank(filemat(index,:))); % loads 3D data
        outmat = temp.outmat(elcs,:,:); 
    
        % filter 3d
        signal3d = filterFGx(outmat,SampRate,Targetfreq,.5);
        
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

        [powsing, freqsing] = FFT_spectrum3D(reshape(RESS_time, 1, size(signal3d, 2), size(signal3d, 3)), timewin, SampRate);
        
        if plotflag, figure(99)
            
        subplot(2,1,1), plot(squeeze(mean(RESS_time, 2)))
        subplot(2,1,2), plot(freqsing(5:70), powsing(1, 5:70)); pause(1)
        end
    

      %eval([' save  ' deblank(filemat(index,1:end-3)) 'RESStim.mat RESS_time -mat']);
      
      SaveAvgFile([deblank(filemat(index,1:end-3)) 'RESSpow.at'],powsing,[],[], fsamp4save);


end % loop over files



    
    
