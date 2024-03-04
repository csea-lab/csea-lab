cd '/Users/csea/Documents/SarahLab/Sarah_Data/pupilProject2023/GenFace_pupil/RawEyeData'
filemat = getfilesindir(pwd,  '*.edf')
filemat2 = getfilesindir(pwd, '*.dat')

for index = 1:size(filemat, 1)


edffull = filemat(index,:)
datafile = deblank(filemat2(index,:))

[matcorr, matout, matoutbsl, percentbadvec, percentbadsub, percentbadcond, avgCond] = genface_eye_pipline_sarah(edffull, datafile, edffull);

end

 
  