% script for dimensional analyses of TF coard data with hoarding, OCD,
% and healthy controls

%first read in the filenames for the three groups
cd '/Users/andreaskeil/Desktop/COARD/COARD_NEW HC allcond wavelet files'
filematHC = getfilesindir(pwd, '*.pow3.mat')

cd '/Users/andreaskeil/Desktop/COARD/COARD_NEW HD allcond wavelet files'
filematHD = getfilesindir(pwd, '*.pow3.mat')

cd '/Users/andreaskeil/Desktop/COARD/COARD_NEW OCD allcond wavelet files'
filematHD = getfilesindir(pwd, '*.pow3.mat')