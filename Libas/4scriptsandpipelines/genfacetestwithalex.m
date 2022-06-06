% genface with Alex test
clear 
% load the data
load('genface_H310.fl40h7.E1.appg.mat')


% load the .ig file because it has the actual artifact free trials as
% indices into the whole experiment (while experiment has 291 trials, 7
% conditions) 
fid = fopen('genface_H310.fl40h7.E1.ig'); 
dummy = fgetl(fid);
indexvectemp = fgetl(fid);
indexvec = str2num(indexvectemp);

if indexvec(end) == 292
    data = outmat(:, :, 1:end-1);
    indexvec(indexvec > 291) = [];
end

% load the log file
VarName4 = importfilegenface('genface_310.dat', 1);
conditions = VarName4(1:291); 
conditions4trials = conditions(indexvec); 






