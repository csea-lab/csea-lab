function [alignedmat] = aligntrialstoexp(ifilemat, singtrialmat, Ntrials); 

for index = 1:size(ifilemat, 1)
        
 [indices,File,Path,FilePath,SizeData] = ReadAscii(deblank(ifilemat(index,:))); 
 
 trialvals = ReadAvgFile(deblank(singtrialmat(index,:))); 
 
 alignedmat = nan(size(trialvals,1), Ntrials); 
 
 alignedmat(:, indices) = trialvals; 
 
 eval(['save ' deblank(singtrialmat(index,:)) 'align.mat alignedmat -mat'])
 
end