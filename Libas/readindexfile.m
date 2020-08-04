function [trialnum] = readindexfile(filepath)
fid = fopen(filepath); 
binaryinfo = fgetl(fid)
trialnum = str2num(binaryinfo); 
trialnum = trialnum(1);
fclose(fid); 

