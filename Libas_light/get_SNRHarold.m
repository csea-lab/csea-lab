function [topo1_43SNR] = get_SNRHarold(filemat)


for fileindex = 1:size(filemat,1); 
    
    data = ReadAvgFile(deblank(filemat(fileindex,:))); 
  
    topo1_43 = data(:, 250); 
   
     topo1_43SNR = topo1_43./mean(data(:, [200:248 252:300]), 2); 

  
    
     SaveAvgFile([deblank(filemat(fileindex,:)) '.RGtagSNR'],topo1_43SNR,[],[],1)
   
     
end    
    


