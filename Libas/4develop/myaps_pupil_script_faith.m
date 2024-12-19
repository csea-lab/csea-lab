% Script for pupil myaps - Faith 

cd '/Users/faithgilbert/Desktop/1_MyAps/Paper/edffiles'

% make matrices that match, start wit myaps 1
filemat_edf = getfilesindir(pwd, 'MyAp5*edf');
filemat_dat = getfilesindir(pwd, 'myaps5*');

filemat_edf = filemat_edf(1:26, :) 
filemat_dat = filemat_dat(1:26,:) 

for subject = 14:size(filemat_dat,1)

 [matcorr, matout, matoutbsl, percentbadvec, percentbadsub, percentbadcond] = eye_pipeline(filemat_edf(subject,:), 500, 'getcon_MyAPS1', filemat_dat(subject,:), 'cue_on', 250, 1500, 1);   

end

