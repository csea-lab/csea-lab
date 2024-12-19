% Script for pupil myaps - Faith 

cd '/Users/faithgilbert/Desktop/1_MyAps/Paper/edffiles'

% make matrices that match, start wit myaps 1
filemat_edf = getfilesindir(pwd, 'MyAp5*edf');
filemat_dat = getfilesindir(pwd, 'myaps5*');

for subject = 14:size(filemat_dat,1)

 [matcorr, matout, matoutbsl, percentbadvec, percentbadsub, percentbadcond] = eye_pipeline(filemat_edf(subject,:), 500, 'getcon_MyAPS1', filemat_dat(subject,:), 'cue_on', 250, 1500, 0);   

end

% myaps 2
filemat_edf = getfilesindir(pwd, 'MyA2*edf');
filemat_dat = getfilesindir(pwd, 'myaps2*');

for subject = 14:size(filemat_dat,1)

 [matcorr, matout, matoutbsl, percentbadvec, percentbadsub, percentbadcond] = eye_pipeline(filemat_edf(subject,:), 500, 'getcon_MyAPS2_ERP', filemat_dat(subject,:), 'cue_on', 250, 1500, 0);   

end

