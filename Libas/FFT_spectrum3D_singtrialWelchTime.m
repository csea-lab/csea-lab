function [alpha3d_Welch, alphapeakHz] = FFT_spectrum3D_singtrialWelchTime(Data3d, SampRate);

% first, determine spectrum and find individual alpha freq

   [specavg, freqs] = FFT_spectrum3D(Data3d, 1:size(Data3d,2), SampRate);
   
        num = sum(freqs(37:77) .* mean(specavg([62 68 72 75], 37:77)));
        
        denom = sum(mean(specavg([62 68 72 75], 37:77)));
        
        alphapeakHz = num / denom
   
      
   for trial = 1: size(Data3d,3)
                 
       for timepoint = 1:size(Data3d, 2)-500
        
%         [Pxx,freqswelch] = pwelch(squeeze(Data3d(:, timepoint:timepoint+499, trial)'),500,100,400,SampRate);
        
         [Pxx, phase, freqswelch] = FFT_spectrum(squeeze(Data3d(:,timepoint:timepoint+499, trial)), SampRate);
        
        % extract the alpha and write out into spec3d_Welch
        
        [val, index] = min(abs(freqswelch-alphapeakHz)); 
        
        alpha3d_Welch(:,timepoint, trial) = Pxx(:,index); 
        
       end
              
       
      if trial/10 == round(trial/10), disp(trial), end
        
    end  % loop over trials
    
%     % smooth the data across trials 
%     for timepoint = 1:size(Data3d, 2)-500
%     alpha3d_Welch(:,timepoint, :) = movingavg_as(squeeze(alpha3d_Welch(:,timepoint, :)), 3); 
%     end
    
    
    
    
  
 	


	