% plotalphaROF
function [alphapower_bsl] = plotalphaROF(filemat, taxis)


for x = 1:size(filemat,1)
    
  a = load(deblank(filemat(x,:))); 
  
  power = a.WaPower; 
  
  power = bslcorrWAMat_div(power, [50:400]);
  
  alphapower = squeeze(mean(mean(power([1 7 14 15], :, 9:14), 1),3)) .* cosinwin(60,1800, 1); 
  
   alphapower_bsl(x,:) = movavg_smooth(alphapower, 200); 
   alphapower_bsl(x,:) = movavg_smooth(alphapower_bsl(x,:), 15); 
   
   figure(22), hold on
   plot(alphapower_bsl(x,:)), pause
  
end
  
alphapower_bsl = bslcorr(alphapower_bsl, 80:180); 

figure(35) 
plot(taxis(60:end-300), (alphapower_bsl(:, 60:end-300))')

figure(25) 
plot(taxis(60:end-300), mean(alphapower_bsl(:, 60:end-300)))