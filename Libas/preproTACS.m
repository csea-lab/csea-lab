
function [datacorr] = preproTACS(filename, startindex, endindex); 

%filename = 'harold_20181210_044444.egi.RAW';

data = ft_read_data([filename]); 

%data = data(:, 98697:298000); 

data = data(:, startindex:endindex); 

% put filter in if it works: 
 [filta, filtb] = butter(3, .005, 'high');
 
 datafilt= filtfilt(filta, filtb, data')';

figure, plot(data(1,:))

datacorr = zeros(size(datafilt)); 

% now the fun part 

for chan = 1:256
    
    fprintf('.'); 
    if round(chan/10) == chan/10, disp(chan), end
    
% assign channel  
datayes = datafilt(chan,:); 

% datacorr is the output. before looping, make sure it has the same szie as
% the input file; 
datacorrtemp = zeros(size(datayes)); 

% loop here across the dataset
% outer loop: is in steps of 3 TRs across the data set, and calculate
% constantly updated templates for subtraction

   for segmentstart = 1:3000:length(datayes) - 3001
    
    dataseg = datayes(segmentstart:segmentstart+2999); 
    
    datacorrseg = zeros(1,3000); 

    for winonset = 1:3
        wintemp(:, :, winonset) = dataseg(:, winonset*1000-999: winonset*1000); 
    end

    template = mean(wintemp, 3);  
    
    % find the 3 starting points for subtracting the template in each
    % segment
    % NOTE! once the correlation crosses 2001, the template needs to lose
    % points at the end !!!!!!!!

        for x = 1:2005
           
            if x>2001 
                templateuse = template(1: end-(x-2001));         
            else
                templateuse = template;
            end
           
            corrvec(x) = corr(dataseg(x:x+length(templateuse)-1)', templateuse'); 
        end
           
     % find the first
      [val, index1] = max(corrvec(1:10)); 
      % find the second
      [val, index2] = max(corrvec(995:1005)); 
      index2 = index2+994; 
      % find the third
      [val, index3] = max(corrvec(1995:2005)); 
       index3 = index3+1994; 
       
        
       datacorrseg(index1:index1+999) = dataseg(:, index1:index1+999)-template; 
       datacorrseg(index2:index2+999) = dataseg(:, index2:index2+999)-template; 
       datacorrseg(index3:index3+999) = dataseg(:, index3:index3+999)-template; 
          
       
       if chan == 136
        figure(999)
         subplot(4,1,1), plot(dataseg)
         subplot(4,1,2), plot(template)
         subplot(4,1,3), plot(corrvec)
         subplot(4,1,4), plot(datacorrseg), pause(.5)
         
       end
         
         
     datacorrtemp(segmentstart:segmentstart+2999) = datacorrseg; 
     
     datacorr(chan, :) = datacorrtemp; 
     
   end
     
     
 
end
