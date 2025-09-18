% concatenates 3-D mats (chan x time points x trials) in the third
function [outmat] = concat_matfiles_3D(filemat, outname)

outmat =[]; 

for fileindex = 1 : size(filemat, 1)
	
	 strucmat = load(deblank(filemat(fileindex, :)), '-mat'); 
    
     mattemp = eval(['strucmat.' char(fieldnames(strucmat))]);

    if ndims(mattemp) == 2
        mattemp = reshape(mattemp, size(mattemp, 1), size(mattemp, 2), 1);
    end
  
    outmat(:, :, fileindex) = mattemp;
 
end

   if ~isempty(outname)
        save(outname, 'outmat', '-mat')
   end
    