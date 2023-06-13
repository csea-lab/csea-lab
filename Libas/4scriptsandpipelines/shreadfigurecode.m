
filemat = getfilesindir(pwd, 'SHREAD_12_*5Hz*mat')
plidiff = summary_shread(filemat)
aha = plidiff(130:end,:)
IPL12_5 = aha(75,:); 


filemat = getfilesindir(pwd, 'SHREAD_12_*6Hz*mat')
plidiff = summary_shread(filemat)
aha = plidiff(130:end,:)
IPL12_6 = aha(75,:); 


filemat = getfilesindir(pwd, 'SHREAD_9_*5Hz*mat')
plidiff = summary_shread(filemat)
aha = plidiff(130:end,:)
IPL9_5 = aha(75,:); 

filemat = getfilesindir(pwd, 'SHREAD_9_*6Hz*mat')
plidiff = summary_shread(filemat)
aha = plidiff(130:end,:)
IPL9_6 = aha(75,:); 



filemat = getfilesindir(pwd, 'SHREAD_6_*5Hz*mat')
plidiff = summary_shread(filemat)
aha = plidiff(130:end,:)
IPL6_5 = aha(75,:); 

filemat = getfilesindir(pwd, 'SHREAD_6_*6Hz*mat')
plidiff = summary_shread(filemat)
aha = plidiff(130:end,:)
IPL6_6 = aha(75,:); 

%% TOPOS
filemat = getfilesindir(pwd, 'SHREAD_6_*z*mat')
[plidiff, phaselock] = summary_shread(filemat);
topophaselock6months_P = mean(phaselock(1:129,:),2);
topophaselock6months_I = mean(phaselock(130:end,:),2);
ipl6month = mean(plidiff(130:end,:),2);
SaveAvgFile('topophaselock6months_P.atg', topophaselock6months_P)
SaveAvgFile('topophaselock6months_I.atg', topophaselock6months_I)
SaveAvgFile('ipl6month.atg', ipl6month)

filemat = getfilesindir(pwd, 'SHREAD_9_*z*mat')
[plidiff, phaselock] = summary_shread(filemat);
topophaselock9months_P = mean(phaselock(1:129,:),2);
topophaselock9months_I = mean(phaselock(130:end,:),2);
ipl9month = mean(plidiff(130:end,:),2);
SaveAvgFile('topophaselock9months_P.atg', topophaselock9months_P)
SaveAvgFile('topophaselock9months_I.atg', topophaselock9months_I)
SaveAvgFile('ipl9month.atg', ipl9month)

filemat = getfilesindir(pwd, 'SHREAD_12_*z*mat')
[plidiff, phaselock] = summary_shread(filemat);
topophaselock12months_P = mean(phaselock(1:129,:),2);
topophaselock12months_I = mean(phaselock(130:end,:),2);
ipl12month = mean(plidiff(130:end,:),2);
SaveAvgFile('topophaselock12months_P.atg', topophaselock12months_P)
SaveAvgFile('topophaselock12months_I.atg', topophaselock12months_I)
SaveAvgFile('ipl12month.atg', ipl12month)



