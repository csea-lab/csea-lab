function[pli_seg] = mov10Hzssvep_hong_Jun2(inmat, div, shiftcycle)
% takes as an input the EEGlab matrix of EEG data in format elcs * time *
% trials, computes 10 Hz movg window for the ssvep period, and estimates
% the 10 Hz power for each sensor and trial


foi = 10; %frequency of interest
Fs = 250; %sample rate 
plotflag = 0;  %0 = off, 1 = plot moving average
fftamp = zeros(size(inmat,1),div); %vector of single trial power estimates 
slot = 2;
fftpwr = zeros(size(inmat,1),div);

sampcycle=1000/250; %added code
tempvec = round((1000/foi)/sampcycle); % this makes sure that average win duration is exactly @@, which is the duration in sp of one cyle at @@ Hz = @@ ms, sampled at 250 Hz
winshiftvec = 1:tempvec:size(inmat,2)-shiftcycle+tempvec;

 if (mod(length(winshiftvec), div)~=0) 
     error('Make sure the average comes from equal number of windows')
 end
 seg_length = length(winshiftvec)/div;
 winshiftmat = zeros(seg_length, div);

for loop = 1:div
    winshiftmat(:,loop) = winshiftvec(seg_length*(loop-1)+1:seg_length*(loop-1)+seg_length);
end
 % need this stuff for the spectrum
 % shiftcycle=round(tempvec*4);
        
        NFFT = 2^nextpow2(shiftcycle*10); % Next power of 2 from length of y
        freqres = Fs/NFFT; %added code to find the appropriate bin for the frequency of interest for each segment
        freqbins = Fs/2*linspace(0,1,NFFT/2+1);
        min_diff_vec = freqbins-foi;  %revised part
        min_diff_vec = abs(min_diff_vec); %revised
        targetbin = find(min_diff_vec==min(min_diff_vec)); %revised        
       
%%

%for trial = 1:size(inmat,3); 
    %Data = squeeze(inmat(:, :, trial)); 
    Data = inmat; % just for one trial
    datamat = Data;
    shiftmat = zeros(size(datamat,1), shiftcycle, size(winshiftmat,1), size(winshiftmat,2));%12*3
    fftphi = zeros(size(datamat,1), size(winshiftmat,1), size(winshiftmat,2));%12*3
	if plotflag, h = figure, end
   for win_seg = 1:size(winshiftmat,2)
       for winshiftstep = 1:size(winshiftmat,1)
            %data_seg = datamat(:,[winshiftvec(winshiftstep):winshiftvec(winshiftstep)+(shiftcycle-1)]);
            data_seg = datamat(:,[winshiftmat(winshiftstep,win_seg):winshiftmat(winshiftstep,win_seg)+(shiftcycle-1)]);
            shiftmat(:, :,  winshiftstep, win_seg) = regressionMAT(data_seg);
            %figure; plot(data_seg(1,:)); temp = regressionMAT(data_seg); hold on; plot(temp(1,:),'r');  % DEBUG
            tspectra = fft(squeeze(shiftmat(:, :,  winshiftstep, win_seg)),NFFT,2)/shiftcycle; % valid frequency 1:NFFT/2+1
            tPhi = tspectra(:,1:NFFT/2+1)./abs(tspectra(:,1:NFFT/2+1)); 
            fftphi(:,winshiftstep, win_seg) = tPhi(:,targetbin);
       end
   end
   pli_seg = squeeze(abs(sum(fftphi, 2))/size(winshiftmat,1));


     