function [repmat] = makerepmat_TF(filemat, Nsubjects, Nconditions, freqindex, optionalbaseline)

% makes  4-D array for contrast_rep 
% if each person/condition file has 3-D 
% (elec by time by freq)
% this selects one frequency and uses the time course of that frequency for
% the repmat

for con = 1:Nconditions
    
   for sub = 1:Nsubjects
       
      index = con + (sub*Nconditions) - Nconditions;
    
      strucmat = load(deblank(filemat(index, :)), '-mat'); 
      mat = eval(['strucmat.' char(fieldnames(strucmat))]);


      
      if ~isempty(optionalbaseline)
          mat = bslcorrWAMat_as(mat, optionalbaseline); 
      end
      

      
            repmat(:, :, sub, con) = squeeze(mat(:, :, freqindex)); 
      

       
   end

   disp(['condition: ' num2str(con)])
   
end
