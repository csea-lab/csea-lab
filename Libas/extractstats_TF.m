function [outmat]  = extractstats_TF(filemat, Nconditions, timeindices, freqindices, electrodes, bslvec); 
% function that extracts one frequency or a frequency band from a wavelet
% or phase locking file

outmat = []; 
filemat_test = []; 
 
for condinum = 1: Nconditions
    
   filemat_con = filemat(condinum:Nconditions:size(filemat,1),:)

    for fileindex = 1:size(filemat_con,1); 

        strucmat = load(deblank(filemat_con(fileindex, :))); 
    
        mat = eval(['strucmat.' char(fieldnames(strucmat))]);
  
          if ~isempty(bslvec)
          mat = bslcorrWAMat_percent(mat, bslvec);
          end

        outvec(fileindex,1) = mean(mean(mean(mat(electrodes, timeindices, freqindices))));
 
        fprintf('.'); 
        
        if fileindex/10==round(fileindex/10), disp(fileindex), end

    end

   outmat = [outmat outvec]; 
   filemat_test = [filemat_test filemat_con] 
end

 

fclose('all')