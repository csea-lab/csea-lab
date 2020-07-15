function [BPM_mat]  = set2HR_NMP_debugfun(filename); 


[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

%will need to think about how to make this into a loop
EEG = pop_loadset('filename', filename);

[ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, 0);

SampRate = EEG.srate;

EEG.data = EEG.data(32,:); %make it only the ECG data
EEG.nbchan = 1;

%%code to segment EEG data, if need be
% if filename(1,6:8) == 'hab';
% EEG = pop_epoch( EEG, {  'S  1'  'S  2'  }, [-3         7]);
% elseif filename(1,6:8) == 'acq';
%     EEG = pop_epoch( EEG, {  'S  3'  'S  4'  }, [-3         7]);
% else
% EEG = pop_epoch( EEG, {  'S  6'  'S  7'  }, [-3         7]);
% end


EEG = eeg_checkset(EEG);

ECGtrialmat = double(squeeze(EEG.data));






% first define useful stuff: 
[B,A] = butter(6,.005, 'high'); %%%adjusted


[C,D] = butter(2, [5/125], 'low');
% secbins are the 1 second segments that are being considereed
secbins = [0.001:9+0.001]; 

%need: samprate


%for fileindex = 1:size(ECGtrialmat,3); 
   
    BPM_mat = [];



time = 0:1000/SampRate:size(ECGtrialmat,1).*1000/SampRate-1000/SampRate; 

%figure

for trial = 1:size(ECGtrialmat,2); 
%for trial =3:4 %single trial debugging    

% read, calculate and plot
   
    
    
    
    [a]=ECGtrialmat(:,trial);
    
    
    ECG =filtfilt(B, A, a);
    
    
    %%%%%
    %put in for worse data that need rectified
     %lowpass
    ECG = filtfilt(C, D, ECG);
    
    %remove the min
    ECG = ECG-min(ECG);
    
    %use this simply for squaring the ECG data
    ECGsquare = ((ECG.^3)); 
    %%%
    
    
    %use this simply for squaring the ECG data
   %ECGsquare = ((ECG.^2)); 
    
    %use this for rectifying the data
    %ECGsquare = (((abs(a)).*-1 - min((abs(a)).*-1)).^2); 
    
  

    
    
    figure('Position', [0, 2000, 2000,1000]);
    
    subplot(2,1,1)
    plot(time, a), title('raw'), 
    
    %plot(time, ECG), title('raw')

    
    subplot(2,1,2)
    plot(time, ECGsquare), title('square')   
    hold on
    
    % find and plot R-peaks
    stdECG = std(ECGsquare); 
    threshold = 1*stdECG; %%may need to change this if data is rectified
    Rchange=  find(ECGsquare > threshold);
    Rstamps = [Rchange(find(diff(Rchange)>20))' Rchange(end)];
    subplot(2,1,2)
    plot(time(Rstamps), 10000, 'r*')
    
    plot(time, threshold);
    
    hold off
 %pause()
       
                 [artifactmode] = input('break for artifact correction?')
                 
                 if artifactmode == 1
                     figure('Position', [0, 2000, 2000,1000]), clf
                     subplot(2,1,1)
                      plot(time, a), title('square'), hold on
                     plot(time(Rstamps), 800, 'r*'), hold off
                     [x,y] = ginput;
                      Rstamps = round(x./(1000/SampRate)) ;
                      length(time)
                      length(Rstamps)
                      length(time(Rstamps))
                      pause()
                      
                      subplot(2,1,2)
                    plot(time, ECGsquare, 'b'), title('square'), hold on
                     plot(time(Rstamps), 800, 'g*'), hold off
                     pause
                 end
        
    % convert to IBIs
     Rwavestamps = time(Rstamps)./1000;
     [ BPMvec ] = HRtest_new(Rwavestamps);
     
     
%%%%%%%%%%%%
%     IBIvec = diff(Rwavestamps)
%     pause
%     leftfornext = 0; 
%     BPMvec = zeros(1,length(secbins)-1);
%     
%     %%%% calculate HR change   
%     
%     
%              for bin_index = 1:length(secbins)-1 % start counting timebins with first time bin until second to last, which has info about the last beat(s)
% 
%               %find cardiac events in and around this timebin and where they are
%               %first find cardiac events that are located entirely in the time bin
% 
%               % ---- 
%                     RindicesInBin1= find(Rwavestamps >= secbins(bin_index));
%                     RindicesInBin2 = min(find(Rwavestamps > secbins(bin_index +1)));
%                     RindicesInBin = min(RindicesInBin1) : RindicesInBin2 -1;
%                     RindicesInBin
%                     
%                     if ~isempty(RindicesInBin); 
%                     maxbincurrent = max(RindicesInBin);
%                     else 
%                         maxbincurrent = 0;
%                     
%                     end
%                     maxbincurrent, pause
%                     if length(RindicesInBin) == 2, % if there are two Rwaves in this segment, the basevalue is always 1 beat, and more may be added
% 
%                             basebeatnum = 1+leftfornext;
% 
%                              %  identify remaining time and determine proportion of next IBI that belongs to this
%                              % segment
%                              
%                              curnumerator = (secbins(bin_index +1) - Rwavestamps(max(RindicesInBin)));
%                             
%                              
%                              
%                               proportion =  curnumerator./IBIvec(max(RindicesInBin));
% 
%                               
%                               if proportion == 0;
%                                   leftfornext = 0;%we did this to correct for double counting a beat
%                               else
%                                 
%                               leftfornext = 1-proportion; end
% 
%                     elseif length(RindicesInBin) == 1,% if there is one Rwave in this segment, the basevalue is what remained from the previous beat, and more may be added
% 
%                             basebeatnum = leftfornext;
% 
%                              % then identify remaining time and determine proportion of next IBI that belongs to this
%                              % segment
%                              
%                              curnumerator = (secbins(bin_index +1) - Rwavestamps(max(RindicesInBin)));
%                              
%                           
%                              
%                                proportion =  curnumerator./IBIvec(max(RindicesInBin));
% 
%                                
%                                
%                                 if proportion == 0;
%                                   leftfornext = 0;%we did this to correct for double counting a beat
%                               else
%                                 
%                               leftfornext = 1-proportion; end
%                                
%                               
% 
%                     else % if there is no beat in this segment
% 
%                         basebeatnum = leftfornext;
% 
%                         if length(IBIvec) >= maxbincurrent+1; 
%                         proportion =  (secbins(bin_index +1) - Rwavestamps(maxbincurrent+1))./IBIvec(maxbincurrent+1);
%                         else
%                             proportion = 1; 
%                         end
% 
%                          leftfornext = abs(proportion);
% 
%                     end
% 
%                  %%%%   
%                  BPMvec(bin_index) = (basebeatnum+proportion) .* 60;
%                  figure; 
%                  plot(BPMvec);
%                  
%                 %%%%added for debugging
%                  proportion
%                  bin_index
%                  proportion
%                  leftfornext
%                  basebeatnum
%                  maxbincurrent
%                  
%                  Rwavestamps
%                  RindicesInBin
%                  IBIvec
%                  
%                 numvec(bin_index) = curnumerator
%                  
%                  
%                  leftfornextvec(bin_index) = leftfornext;
%                  Rindexlengthvec(bin_index) = length(RindicesInBin);
%                  bin_indexvec(bin_index) = bin_index;
%                  proportionvec(bin_index) = proportion;
%                  leftfornextvec(bin_index) = leftfornext;
%                  basebeatnumvec(bin_index) = basebeatnum;
%                  maxbincurrentvec(bin_index) = maxbincurrent;
%                  RindicesInBin
%                  RindicesInBin1
%                  RindicesInBin2
%                  
%                  
%                  
%                 pause(); 
                 
                
                %%%%%%%%%%%%%
                
                
                
           % end % loop over bin indices
%              IBIvec
%                BPMvec(1) = 1./IBIvec(1).*60; 
%                  BPMvec(end) = 1./IBIvec(end).*60;  
%              
%              figure(1)    
%              subplot(3,1,3)
            subplot(2,1,1), plot(BPMvec); pause(1); disp(num2str(size(BPMvec))); 
%                  
                   BPM_mat = [BPM_mat; BPMvec];
% %              
    close all
 end %trial

fclose('all'); 
%end % fileindex


