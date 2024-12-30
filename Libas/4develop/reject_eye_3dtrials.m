function [ inmat3d, badindex, NGoodtrials ] = reject_eye_3dtrials(inmat3d, horipair, vertipair, threshold);
% caluclate three metrics of data quality at the trial level

    horidata = 
    
    badindex = find(absvalvec > threshold);
    
    inmat3d(:, :, badindex) = []; 
    
    NGoodtrials = size(inmat3d,3);



