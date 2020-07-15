function [filematout] = sortfilenames4spm(filemat, blockdotnumstr, outfolder)
% blockdotnumstr , e.g. '.4.'

filematout = [];
maxlength = size(filemat,2);

for index = 1:size(filemat, 1)
    
    actuallength = length(deblank(filemat(index,:))); 
   if maxlength - actuallength == 2; 
    blocklocation =  findstr(filemat(1,:), blockdotnumstr); 
    filematout(index,:) = [filemat(index,1:blocklocation+2) '00' filemat(index,blocklocation+3:end-2)];
   elseif maxlength - actuallength == 1; 
    blocklocation =  findstr(filemat(1,:), blockdotnumstr); 
    filematout(index,:) = [filemat(index,1:blocklocation+2) '0' filemat(index,blocklocation+3:end-1)];    
   else
    filematout(index,:) = filemat(index,:); 
   end
    
end
    
filematout = char(filematout); 

if ~exist([pwd '/' outfolder], 'dir')
    mkdir(pwd, outfolder)
end

for index = 1:size(filematout,1)
    copyfile(deblank(filemat(index,:)), [pwd '/' outfolder '/' filematout(index,:)])
end
    
