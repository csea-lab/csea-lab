function [outmat] = get_tagbins(filemat, binindex, suffix);

outmat = []; 

for fileindex = 1:size(filemat,1); 
    
    data = ReadAvgFile(deblank(filemat(fileindex,:))); 
    
    topo  = data(:, binindex); 
    
    
  SaveAvgFile([deblank(filemat(fileindex,:)) '.' suffix],topo,[],[],1)
 
end    