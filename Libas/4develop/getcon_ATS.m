function convec= getcon_ATS(csvpath)
% this is the provisional getcon for the EEG pipeline for Janna's ATS study

temp = readtable(csvpath);

convec = table2array(temp(:,2));