function [conditionvec] = getCon_newWurz_singleTrial(filepath)
%first, read in a new_wurz log file with RTs and everything
table = readtable(filepath);
conditionvec = table2array(table(:, 1));


% if subject 226 and beyond, add a code for second event marker

