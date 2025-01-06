function [ outmat3d, badindextotal, NGoodtrials ] = reject_eye_3dtrials(inmat3d, horipair, vertipair, threshold)
% calculate three metrics of data quality at the trial level
% for 256 EGI: horipair = [226, 252]; vertipair = [238, 10];

   outmat3d = inmat3d; 

    horidata = squeeze(inmat3d(horipair(1),:,:)-inmat3d(horipair(2),:,:)); % Heog

    vertidata = squeeze(inmat3d(vertipair(1), :, :)-inmat3d(vertipair(2), :, :)); % right VEOG
    
    badindex_hori = find(squeeze(max(horidata', [], 2)) > threshold);
    
    badindex_verti = find(squeeze(max(vertidata', [], 2)) > threshold);

    badindextotal = unique(cat(1, badindex_hori, badindex_verti));
    
    outmat3d(:, :, badindextotal) = []; 
    
    NGoodtrials = size(outmat3d,3);



