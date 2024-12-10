%%Calls function "eye_pipeline.m"
%Need edf file and condition files as inputs

%%Pathway for edf and condition files
cd '/Users/csea/Documents/SarahLab/Sarah_Data/IAPs_2'

%Lists .edf and condition file names as filemat and filemat2, respectively
filemat = getfilesindir(pwd,  '*.edf')
filemat2 = getfilesindir(pwd, '*.dat')

%Sample Rate
sRate = 500
%Condition vector function name
convecfun = 'getcon_MyAPS2_ERP.m'
%trigger onset name
trigname = 'cue_on'
%time before stimulus onset in sample points
pre_onsetSP = 
%time after stimulus onset in sample points
post_onsetSP = 

%for all edf files listed in filemat...
for index = 1:size(filemat, 1)

edffull = filemat(index,:)
%condition file name
confile = deblank(filemat2(index,:))

plotflag = 1

[matcorr, matout, matoutbsl, percentbadvec, percentbadsub, percentbadcond] = eye_pipeline(edffull, sRate, convecfun, confile, trigname, pre_onsetSP, post_onsetSP, plotflag);
pause
end

