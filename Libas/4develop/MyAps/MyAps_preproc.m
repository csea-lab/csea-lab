clear

cd '/Users/csea/Documents/SarahLab/Sarah_Data/IAPs'


filemat = getfilesindir(pwd,  '*.edf')
filemat2 = getfilesindir(pwd, '*.dat')

    for index = 1:size(filemat, 1);
    
        outname = deblank(filemat(index,:));
        edffull = deblank(filemat(index,:));
        datafile = deblank(filemat2(index,:));
        
        [matcorr, matout, matoutbsl, percentbadvec, percentbadsub, percentbadcond] = MyAps_eye_pipline_sarah(edffull, datafile, outname);
        
        pause(.5)
     
    end