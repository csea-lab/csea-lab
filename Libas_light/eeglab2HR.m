function [BPM, spectrum, frequencies]  = eeglab2HR(segment, samplerate, threshfac); 

if nargin < 3, threshfac = []; end

BPM = []; 
spectrum = []; 
frequencies = []; 

time = 0:1000/samplerate:length(segment)*1000/samplerate-1000/samplerate; 
time = time./1000; 
length(time);
length(segment)'


    
    [B,A] = butter(6,.05, 'high'); % first define a 6th order higpass filter at 0.025 of the sample rate (gets rif of drift)

    ECG =filtfilt(B, A, segment); % filter the segment
    
    ECGsquare = [ ((ECG).^2)]; % square   the segment, to increase the signal to noise of the R wave
     
    subplot(2,1,1), plot(time, ECG), title('raw EKG')

   subplot(2,1,2),  plot(time, ECGsquare), title('integrated EKG'), hold on
   
    % find and plot R-peaks
    stdECG = std(ECGsquare); 
    threshold = 4.1*stdECG; 
    Rchange=  find(ECGsquare > threshold);
    Rstamps = [Rchange(find(diff(Rchange)>10)) Rchange(end)];
    subplot(2,1,2)
    plot(time(Rstamps), threshold, 'r*')
    
    
    % calculate IBIs and BPM
   Rwavestamps = time(Rstamps);
   IBIvec = diff(Rwavestamps);
   medIBI =  median(IBIvec); 
   BPM = median(1./IBIvec.*60)
    
   
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
            plot(RwavestampsNew, 1.4*threshold, 'g*') 
            Rwavestamps = RwavestampsNew; 
            
            BPM = median(1./diff(RwavestampsNew)).*60; 
   
    end % if thresfac
  
    hold off
         
    % calculate the HRV spectrum
    vec = zeros(1, length(time));
    vec(round(Rwavestamps.*1000)) = 1; 
    [spectrum, frequencies] = FFT_spectrum(vec, samplerate);
    figure, plot(frequencies(2:100), spectrum(2:100)); 

    
   



