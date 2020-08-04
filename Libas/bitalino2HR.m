function [BPM,  BPMvec, skin, skinvec]  = bitalino2HR(datamat, segment, samplerate, threshfac); 

if nargin < 3, threshfac = []; end

BPM = []; 
IBIsd = [];
IBIall = [];
RMSSD = [];



time = 0:1000/samplerate:length(segment)*1000/samplerate-1000/samplerate;
time = time./1000;

    
    [B,A] = butter(6,.05, 'high'); % first define a 6th order higpass filter at 0.025 of the sample rate (gets rif of drift)

    ECG =filtfilt(B, A, datamat(segment,8)'); % filter the segment   
    
    ECGsquare = [ ((ECG).^2)]; % square the derivative of the segment, to increase the signal to noise of the R wave
     
    figure, title('heart rate')
    
    subplot(2,1,1), plot(time, ECG), title('raw EKG')

    subplot(2,1,2),  plot(time, ECGsquare), title('derivative / integrated EKG'), hold on
   
    % find and plot R-peaks
    stdECG = std(ECGsquare); 
    threshold = 2.5*stdECG; 
    Rchange=  find(ECGsquare > threshold);
    Rstamps = [Rchange(find(diff(Rchange)>10)) Rchange(end)];
   subplot(2,1,2)
   plot(time(Rstamps), threshold, 'r*')
    
    
    % calculate IBIs and BPM
   Rwavestamps = time(Rstamps);
   IBIvec = diff(Rwavestamps);
   IBIsd = std(IBIvec);
   IBIall=IBIvec*1;
   IBIall2=[IBIall(2:end)];
   IBIall1=[IBIall(1:(end-1))];
   IBIallsq=(IBIall2-IBIall1).^2;
   medIBI =  median(IBIvec); 
   rawRMSSD = sqrt((sum(IBIallsq))*(1/(length(IBIall)-1))); % Root mean square of the difference between adjacent IBIs, needs mult. *1000 to get msec
   RMSSD=rawRMSSD*1000;
   
   
    % artfact correction, only if threshfac is entered
    if ~isempty(threshfac)
         upperlimit = medIBI+ threshfac* std(IBIvec);
         lowerlimit = medIBI - threshfac* std(IBIvec);
 
            RwavestampsNew = Rwavestamps(1);  % user makes sure first R-wave is real 

            nextskip = 0;
            for x = 1:length(Rwavestamps)-1
                if nextskip, RwavestampsNew = RwavestampsNew; nextskip = 0; 
                else
                    if IBIvec(x) < lowerlimit, 
                        RwavestampsNew = [RwavestampsNew Rwavestamps(x)]; nextskip = 1; 
                     elseif IBIvec(x) > upperlimit, 
                        RwavestampsNew = [RwavestampsNew RwavestampsNew(end)+ round(medIBI)];
                    else
                       RwavestampsNew = [RwavestampsNew Rwavestamps(x)];
                    end   
                end
            end

            if IBIvec(end) > lowerlimit, RwavestampsNew = [RwavestampsNew Rwavestamps(end)]; end

            % second pass to find diehard artifacts
            IBIvecNew = diff(RwavestampsNew); 
            diehardindex = find(IBIvecNew < lowerlimit); diehardindex = diehardindex(2:length(diehardindex)); 
            RwavestampsNew(diehardindex) = [];
            plot(RwavestampsNew, 1.4*threshold, 'g*');
            Rwavestamps = RwavestampsNew; 
            IBIvec = IBIvecNew;
            
            BPM = median(1./diff(RwavestampsNew)).*60; 
   
    end % if thresfac
  
    hold off
         
    % calculate the HRV spectrum
    vec = zeros(1, length(time));
    vec(round(Rwavestamps.*1000)) = 1; 
    [spectrum, frequencies] = FFT_spectrum(vec, samplerate);
    %figure, plot(frequencies(2:100), spectrum(2:100)); 
    
    
    % calculate HR over time
    secbins = [Rwavestamps(1):Rwavestamps(end)];
   
    leftfornext = 0; 
    BPMvec = zeros(1,length(secbins)-1);
    
     for bin_index = 1:length(secbins)-1 
          RindicesInBin1= find(Rwavestamps >= secbins(bin_index));
            RindicesInBin2 = min(find(Rwavestamps > secbins(bin_index +1)));
            RindicesInBin = min(RindicesInBin1) : RindicesInBin2 -1;

            if ~isempty(RindicesInBin); 
            maxbincurrent = max(RindicesInBin);
            end

            if length(RindicesInBin) == 2, % if there are two Rwaves in this segment, the basevalue is always 1 beat, and more may be added

                    basebeatnum = 1+leftfornext;

                     %  identify remaining time and determine proportion of next IBI that belongs to this
                     % segment
                      proportion =  (secbins(bin_index +1) - Rwavestamps(max(RindicesInBin)))./IBIvec(max(RindicesInBin));

                      leftfornext = 1-proportion;

            elseif length(RindicesInBin) == 1,% if there is one Rwave in this segment, the basevalue is what remained from the previous beat, and more may be added

                    basebeatnum = leftfornext;

                     % then identify remaining time and determine proportion of next IBI that belongs to this
                     % segment
                       proportion =  (secbins(bin_index +1) - Rwavestamps(max(RindicesInBin)))./IBIvec(max(RindicesInBin));

                       leftfornext = 1-proportion;

            else % if there is no beat in this segment
                
                basebeatnum = leftfornext;
                
                if length(IBIvec) >= maxbincurrent+1; 
                proportion =  (secbins(bin_index +1) - Rwavestamps(maxbincurrent+1))./IBIvec(maxbincurrent+1);
                else
                    proportion = 1; 
                end

                 leftfornext = abs(proportion);

            end

         BPMvec(bin_index) = (basebeatnum+proportion) .* 60;

    end
         
         
     for index2 = 1:length(BPMvec)
         if BPMvec(index2)>median(BPMvec).*1.3; BPMvec(index2) = median(BPMvec); 
         elseif BPMvec(index2)<median(BPMvec).*0.7; BPMvec(index2) = median(BPMvec); 
         end
     end

    BPM = median(BPMvec);
   
    figure
    title('skin'); 
    skin = median(datamat(segment, 7));
    skinvec = datamat(segment, 7); 
    plot(time, skinvec); 
   



