function [ outmat ] = correctECOGstrips( inmat )
% this one is suitable for strips

allchans = 1:size(inmat,1); 

outmat  = inmat; 

 for trial = 1:size(inmat, 3)
     
     badchans = []; 
     
     trialmat = squeeze(inmat(:, :, trial));
     datatrialout = trialmat; 
     
     tempmat = abs(diff( trialmat')'); 
 
     
     [row1, col] = find(tempmat > median(std(tempmat)).*20);
     row1
     
     [row2, col] = find(mean(abs(tempmat),2) < 0.3); 
     row2
     
       [row3, col] = find(mean(abs(trialmat),2) >100); 
     row3
    
     badchans = unique([row1; row2; row3]), length(badchans)
     
     goodchans = allchans(~ismember(allchans, badchans)); length(goodchans)
     
        if length(goodchans) > 2; 
            subset_temp = randperm(length(goodchans)); 
            subset = subset_temp(1:end-1); 
            goodchans = goodchans(subset)
         
         newchandata = mean(trialmat(goodchans, :), 1); 
        
         %figure (99), plot(newchandata); 
         
         elseif length(goodchans) <= 2 && length(goodchans) > 0
             
         newchandata = trialmat(goodchans(1), :); 
         
        else
            
         newchandata = ones(size(trialmat(1,:))); 
         
        end
            
         
         for badchanindex = 1:length(badchans)            
             datatrialout(badchans(badchanindex), :)  = newchandata; 
         end
         
         outmat(:, :, trial) = datatrialout; 

         figure(1), plot(datatrialout'), pause(.1)
         
 end

