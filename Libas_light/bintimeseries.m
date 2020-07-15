function [binmat] = bintimeseries(inmat, binsize); 

count = 1;

for x = 1:binsize:size(inmat,2)   
          
    binmat(:, count) = nanmean(inmat(:, x:x+binsize-1),2);
    
    count = count + 1;
        
end 