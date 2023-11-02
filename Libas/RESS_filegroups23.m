function [RESS_time] = RESS_filegroups23(filemat, elcs, timewin, SampRate, Targetfreq, plotflag) 
% gets a number of files that HAVE to be from one person, e.g. all
% conditions for that person, to obtain many trials for stable RESS filter
% estimate; it then aggregates all trials into ine matrix, and calculates
% the RESS filter, then applies to individual files
% elcs  = electrodes to include (not toooooo many) 
% timewin = which sample points to include

fsamp4save = 1000./(SampRate./length(timewin));

% 1. make matrix with all trials to compute robust RESS
outmat_all = []; 
for index = 1:size(filemat,1)
    temp = load(deblank(filemat(index,:))); % loads 3D data
    outmat_all = cat(3, outmat_all, temp.outmat(elcs,:,:)); 
end
    
% 2. find the best spatial filter for the ssvep
        % filter 3d
        signal3d = filterFGx(outmat_all,SampRate,Targetfreq,.5);
        referenceUP3d = filterFGx(outmat_all,SampRate,Targetfreq+1,1);
        referenceLO3d = filterFGx(outmat_all,SampRate,Targetfreq-1,1);

         % reshape, time, and baseline
         signal = reshape(signal3d(:, timewin, :), size(outmat_all,1), []); 
         signal = bsxfun(@minus,signal,mean(signal,2));

         referenceUP = reshape(referenceUP3d(:, timewin, :), size(outmat_all,1), []); 
         referenceUP = bsxfun(@minus,referenceUP,mean(referenceUP,2));

         referenceLO = reshape(referenceLO3d(:, timewin, :), size(outmat_all,1), []); 
         referenceLO = bsxfun(@minus,referenceLO,mean(referenceLO,2));

          % covariance   
          Sigcov = (signal * signal')./range(timewin);
          RefcovUP = (referenceUP * referenceUP')./range(timewin);
          RefcovLO = (referenceLO * referenceLO')./range(timewin);

          [W,L]=eig(Sigcov, (RefcovUP+RefcovLO)./2);
          [~,comp2plot] = max(diag(L)); % find maximum component

  % 3. reconstruct RESS component time series for each trial and condition
       for index = 1:size(filemat,1)
            RESS_time = [];
            temp = load(deblank(filemat(index,:))); % loads 3D data
            outmat = temp.outmat(elcs,:,:); 
      
            for trial = 1:size(outmat,3)
            RESS_time( :, trial) = W(:,comp2plot)'*squeeze(outmat(:,:, trial));
            end % trial loop 
            
            [powsing, freqsing] = FFT_spectrum3D(reshape(RESS_time, 1, size(RESS_time, 1), size(RESS_time, 2)), timewin, SampRate);
                
            if plotflag, figure(99)
                subplot(2,1,1), plot(squeeze(mean(RESS_time, 2)))
                title(deblank(filemat(index,1:end-3)))
                subplot(2,1,2), bar(freqsing(5:200), powsing(1, 5:200)); pause
            end

       %eval([' save  ' deblank(filemat(index,1:end-3)) 'RESStim.mat RESS_time -mat']);
       SaveAvgFile([deblank(filemat(index,1:end-3)) 'RESSpow.at'],powsing,[],[], fsamp4save);

       end  % file loop
    
end % function


    
    
