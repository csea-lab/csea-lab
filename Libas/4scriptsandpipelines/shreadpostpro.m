function [PLImat] = shreadpostpro(datfilepath, setfilepath_p, setfilepath_i)

eeglab


PLImat = [];


[convec] = SHREAD_getcontrial(datfilepath); 

EEG_p = pop_loadset(setfilepath_p);

EEG_i = pop_loadset(setfilepath_i);



