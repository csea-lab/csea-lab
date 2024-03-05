%% IAPs Pupil - Sarah
function [matcorr, matout] = IAPs_eye_pipline_sarah(edffull, datafile, edffile)

datamat = Edf2Mat(edffull);

pupilbycond = [];

for x = 1:length(datamat.Events.Messages.info)
     if findstr('cue_on', char(datamat.Events.Messages.info(x)))
         trialindexinMSGvec = [trialindexinMSGvec datamat.Events.Messages.time(x)]; 
     end
 end

startbins = trialindexinMSGvec; 
 
datavec = datamat.Samples.pupilSize;