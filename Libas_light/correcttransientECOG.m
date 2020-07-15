function [ outmat ] = correcttransientECOG( filemat, basename )
% this one is suitabel for larger grids with > 10 sensors


for file = 1:8
    
    temp = load(deblank(filemat(file, :))); 
    
    inmat= temp.data.FG;
    
   allchans = 1:size(inmat,1); 

c  = inmat; 

 for trial = 1:size(inmat, 3)
     
     trialmat = squeeze(inmat(:, :, trial));
     datatrialout = trialmat; 
     
     tempmat = abs(diff( trialmat')'); 
 
     
     [row1, col] = find(tempmat > std(std(tempmat)).*15); 
     
     [row2, col] = find(mean(abs(tempmat),2) < 0.2)
    
     badchans = unique([row1; row2]); length(badchans)
     
     goodchans = allchans(~ismember(allchans, badchans)); length(goodchans)
     
        if length(goodchans) > 2; 
            subset_temp = randperm(length(goodchans)); 
            subset = subset_temp(1:end-1); 
            goodchans = goodchans(subset)
         
         newchandata = mean(trialmat(goodchans, :), 1); 
       
   %      if trial/10 == round(trial./10)
         figure (99), plot(newchandata); pause(0.5)
  %       end
         
         elseif length(goodchans) <= 2 && length(goodchans) > 0
             
         newchandata = trialmat(goodchans(1), :); 
         
        else
            
         newchandata = ones(size(trialmat(1,:))); 
         
        end
            
         
         for badchanindex = 1:length(badchans)            
             datatrialout(badchans(badchanindex), :)  = newchandata; 
         end
         
    outmat(:, :, trial)   = datatrialout; 
         
%figure(1), plot(datatrialout'), pause
         
 end
 
 eval(['save ' basename num2str(file) '.mat outmat'])
 
end

