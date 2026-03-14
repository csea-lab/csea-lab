function [repmat] = makerepmat_TF(filemat, Nsubjects, electrode, Nconditions, optionalbaseline)

% makes  4-D array for contrast_rep 
% if each person/condition file has 3-D 
% (elec by time by freq)

% the repmat has only one electrode

for con = 1:Nconditions
    
   for sub = 1:Nsubjects
       
      index = con + (sub*Nconditions) - Nconditions;
    
      strucmat = load(deblank(filemat(index, :)), '-mat'); 
      mat = eval(['strucmat.' char(fieldnames(strucmat))]);


      
      if ~isempty(optionalbaseline)
          mat = bslcorrWAMat_as(mat, optionalbaseline); 
      end
      

      
            repmat(:, :, sub, con) = squeeze(mat(electrode, :, :)); 
      

       
   end

   disp(['condition: ' num2str(con)])
   
end
