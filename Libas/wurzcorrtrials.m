function [indices] = wurzcorrtrials(ifilepath,datfilepath)

    

% first, read the ifile to get the indices
fid1 = fopen(ifilepath); 
fgetl(fid1); % this is the header 
temp = fgetl(fid1); % this is the indices 
indices = str2num(temp); 


% second, find the trials with responses
fid2 = fopen(datfilepath); 


