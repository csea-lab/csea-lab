function convec = getcon_PAL(filename)
%IMPORTFILE Import data from a text file
%  reads data from mat file FILENAME
%  for the default selection.  Returns the data as column vectors.
tmp = load(filename); 
convec = tmp.trialImageOrder'; 