function [meanBPMvec, BPMmat, secbins]  = Brainamp2HR(datavec, triggervec, threshfac); 

if nargin < 3, threshfac = []; end

BPM = []; 
IBIsd = [];
IBIall = [];
RMSSD = [];
BPMmat = []; 

maxbincurrent = 1; %default

% convert to ms 
datavec = datavec.*4; 
triggervec = triggervec .*4;

% find epochs, relative to stimulus onset, get rid of stims at the very
% beginning
epochstartindex = find(triggervec(3:end-3) > 0); 
epochstartindex = epochstartindex+2;   % realign triggers so that indices match with data


% loop over trials
for x = 1:length(epochstartindex)
    % stim is reference point (epochstart). go back 3 beats and 6 forward
    % from there
      epoch = [datavec(epochstartindex(x) - 3:epochstartindex(x)+7)]-triggervec(epochstartindex(x))+3000; 
    
    % get rid of 0 which is stim itself, the time stamp of the trigger is
    % already used 
      epoch(4) = [];
    
    % make time bins in ms, aligned with trigger and timestamps (epoch), 3
    % seconds baseline
      secbins = [epochstartindex(x)-3000:500:epochstartindex(x)+6500] - epochstartindex(x)+3000;
      diff(epoch); % claculate IBIs for each Rwave in the epoch

    % transform everything to seconds, so can use existing code
      secbins = secbins./1000; 
      Rwavestamps = epoch./1000;


% from here it is much better ti use IBI2HRchange_halfsec.m below is the original fran graham algorithm from the 1980s, but it can be replaced by linear interpolation in matlab with onel line of code...
    
    IBIvec = diff(Rwavestamps);
  
     % calculate HR over time
     leftfornext = 0; 
     
     BPMvec = zeros(1,length(secbins)-1);
     
          for bin_index = 1:length(secbins)-1 % loop over bins
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

         BPMvec(bin_index) = (basebeatnum+proportion) .* 120; % it is 120 and not 60 because we have half second bins
              

          end  % loop over secbins
         
               if~isempty(threshfac )    
                     for index2 = 1:length(BPMvec)
                         if BPMvec(index2)>median(BPMvec).*(1+threshfac); BPMvec(index2) = median(BPMvec); 
                         elseif BPMvec(index2)<median(BPMvec).*(1-threshfac); BPMvec(index2) = median(BPMvec); 
                         end
                     end
               end
        
        BPMvec(1:4) = [mean(BPMvec(1:end-4)) mean(BPMvec(2:end-3)) mean(BPMvec(3:end-2)) mean(BPMvec(4:end))];
        
         
         BPMmat = [BPMmat; BPMvec];
           
        BPM = median(BPMvec); 
    
end % epoch loop

    
meanBPMvec = mean(BPMmat);  % average across trials 