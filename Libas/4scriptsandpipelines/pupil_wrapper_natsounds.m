

filemat_edf = getfilesindir(pwd, '*edf'); 
filemat_dat = getfilesindir(pwd, '*dat'); 

for x = 66:66
[matcorr, matout, matoutbsl, percentbadvec, percentbadsub, percentbadcond] = eye_pipeline(deblank(filemat_edf(x,:)), 500, 'getcon_natsounds', deblank(filemat_dat(x,:)), 'Cue_on', 300, 3000, 1); 
end