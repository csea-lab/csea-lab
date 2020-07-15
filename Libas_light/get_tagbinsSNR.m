function [topo_SNR] = get_tagbinsSNR(filemat, targetbin, noisebins, outname);


for fileindex = 1:size(filemat,1); 
    
    data = ReadAvgFile(deblank(filemat(fileindex,:))); 
    
         
    topotag = data(:, targetbin); 
   
    
  % and now do the SNR
  topo_SNR = topotag./mean(data(:, noisebins),2); 
    
     SaveAvgFile([deblank(filemat(fileindex,:)) '.SNR.' outname],topo_SNR,[],[],1)
   
     
end    
    


