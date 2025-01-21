function [] = make_pipeline_folderstruc(foldername, prefix, raw_ID_index, dat_ID_index, dataindex)
% takes a bunch of files and puts them into the right folder structure for
% the LB3 pipeline, one folder for each subject, containing raw and dat

if nargin < 5,  dataindex= []; end

cd (foldername)

rawfiles = getfilesindir(pwd, '*.RAW');
raw_IDs = rawfiles(:, raw_ID_index);
sorted_Raw_IDs = sort(str2num(raw_IDs));

datfiles = getfilesindir(pwd, '*.dat');
dat_IDs = datfiles(:, dat_ID_index); 
sorted_dat_IDs = sort(str2num(dat_IDs));

if isempty(dataindex ), dataindex = size(rawfiles, 1); end

for subjectindex = 1:dataindex % only unti the two lists diverge

  datfile = getfilesindir(pwd, ['*' num2str(sorted_dat_IDs(subjectindex)) '*.dat']);
  rawfile = getfilesindir(pwd, ['*' num2str(sorted_Raw_IDs(subjectindex)) '*.RAW']);

  newfolder = [prefix num2str(sorted_Raw_IDs(subjectindex))]; 
  mkdir(newfolder)

  copyfile(datfile, newfolder )
  copyfile(rawfile, newfolder )
  pause(3)

end




