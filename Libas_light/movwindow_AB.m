function[fftamp, winmat3d,spectrum3d, targetbin, shiftmat, PLVshift] = movwindow_AB(inmat, outname, foi, samprate, plotflag, ssvepvec)
% takes as an input the EEGlab matrix of EEG data in format elcs * time *
% trials, computes 10 Hz movg window for the ssvep period, and estimates
% the 10 Hz power for each sensor and trial

% %FOR POST T1 ssVEP
% foi = 8.62; %frequency of interest
% samprate = 250; %sample rate 
% plotflag = 0;  %0 = off, 1 = plot moving average
% ssvepvec = 276:825;  %window of the eeg data to analyze. FOR POST T1
% fftamp = []; %vector of single trial power estimates 
% PLVshift = []; %vector of single trial phase stability estimates 
% PLV = zeros(1, size(inmat,1), size(inmat,3)); 
% winmat3d = []; 
% 
%FOR POST T1 Alpha
% foi = 10; %frequency of interest
% samprate = 250; %sample rate 
% plotflag = 0;  %0 = off, 1 = plot moving average
% ssvepvec = 276:825;  %window of the eeg data to analyze. FOR POST T1
fftamp = []; %vector of single trial power estimates 
PLVshift = []; %vector of single trial phase stability estimates 
PLV = zeros(1, size(inmat,1), size(inmat,3)); 
winmat3d = []; 

 sampcycle=1000/samprate; %added code
 tempvec = round((1000/foi)/sampcycle); % this makes sure that average win duration is exactly @@, which is the duration in sp of one cyle at @@ Hz = @@ ms, sampled at 250 Hz
 longvec = repmat(tempvec,1,200); % repeat this many times, at least for duration of entire epoch, subsegments are created later 
 winshiftvec_long = cumsum(longvec)+ ssvepvec(1); % use cumsum function to create growing vector of indices for start of the winshift
 tempindexvec = find(winshiftvec_long > ssvepvec(length(ssvepvec))); 
 
 endindex = tempindexvec(1);  % this is the first index for which the winshiftvector exceeds the data segment 
 winshiftvec = winshiftvec_long(1:endindex-5);

 % need this stuff for the spectrum
 shiftcycle=round(tempvec*[1000/600]);%changed from 4
  samp=1000/samprate;
        freqres = 1000/(shiftcycle*samp); %added code to find the appropriate bin for the frequency of interest for each segment
        freqbins = 0:freqres:(samprate/2); 
        min_diff_vec = freqbins-foi;  %revised part
        min_diff_vec = abs(min_diff_vec); %revised
        targetbin=find(min_diff_vec==min(min_diff_vec)); %revised 

% disp('moving window procedure')
for trial = 1:size(inmat,3); 
%     fprintf('.')
        
      Data = squeeze(inmat(:, :, trial)); 
     

      datamat = Data;

    %===========================================================
	% 3. moving window procedure 
	% 
	%===========================================================
	
    shiftmat = zeros(size(datamat,1), shiftcycle, length(winshiftvec));

	if plotflag, h = figure, end
   
   for winshiftstep = 1:length(winshiftvec)
        
%     size(winshiftstep)
%     size(winshiftvec)
%        pause()
        shiftmat(:, :, winshiftstep) = regressionMAT(datamat(:,[winshiftvec(winshiftstep):winshiftvec(winshiftstep)+(shiftcycle-1)]));     
        
       if plotflag
           subplot(2,1,2), plot(1:4:shiftcycle*4, regressionMAT(datamat(:,[winshiftvec(winshiftstep):winshiftvec(winshiftstep)+(shiftcycle-1)]))'), title(['sliding window starting at ' num2str((winshiftvec(winshiftstep))*4)  ' ms ']), xlabel('time in milliseconds')
           subplot(2,1,1), plot(1:4:shiftcycle*4, mean(shiftmat, 3)'), title(['mean of sliding windows; number of shifts:' num2str(winshiftstep) ]), ylabel('microvolts')
              %subplot(3,1,3), hold on, circle([0,0],1,200,'-');
              %plot([0;(imag(fouriercomp(120)./tenHZampfft(120)))], [0;(real(fouriercomp(120)./tenHZampfft(120)))]);title('phase angle of window') 
           pause(.4)
       end
 
    end
      
    winmat = mean(shiftmat, 3);  
    
    if trial == 1; 
        winmat3d = winmat; 
    else
        winmat3d(:, :, trial) = winmat; 
    end
    
    
    % power/amplitude for each trial's average (after shifting and
    % averaging windows)
    
    NFFT = shiftcycle-1; %one cycle in sp of the desired frequency times 4 oscillations (-1)
	NumUniquePts = ceil((NFFT+1)/2); 
	fftMat = fft (winmat', (shiftcycle-1));  % transpose: channels as columns (fft columnwise)
	Mag = abs(fftMat);                                                   % Amplitude berechnen
	Mag = Mag*2;   

	Mag(1) = Mag(1)/2;                                                    % DC trat aber nicht doppelt auf
	if ~rem(NFFT,2),                                                    % Nyquist Frequenz (falls vorhanden) auch nicht doppelt
        Mag(length(Mag))=Mag(length(Mag))/2;
	end

	Mag=Mag/NFFT;  % FFT normalized such that independent of number of points
    
     if trial == 1; 
        spectrum3d = Mag'; 
    else
        spectrum3d(:, :, trial) = Mag'; 
    end
    
    fftamp = [fftamp Mag(targetbin,:)'];
    
  
   % phase stability (pli, plv) across the shifting and averaging windows
    
ffttemp = fft(shiftmat,100, 2); %FFT across time point
ffttempnorm = ffttemp./abs(ffttemp); % normalize to unit circle
ffttempnorm_mean = squeeze(mean(ffttempnorm, 3)); % complex phase average across window shifts
PLVspec = abs(ffttempnorm_mean); % take abs value (length of vector) after averaging
PLVshift = [PLVshift PLVspec(:, targetbin)]; 

end

SaveAvgFile(outname,fftamp);
SaveAvgFile([outname '.at.plv'],PLVshift);
    
     