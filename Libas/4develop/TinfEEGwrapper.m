% tinf EEG wrapper 

cd '/Users/andreaskeil/UF Dropbox/Andreas Keil/transitive_inference/Data/par_802/'

datapath = 'tinf_802.RAW'; 

conditions2select = { '11' '12' '13' '14' '15'  '21' '22' '23' '24' '31' '32' '33' '34' };

[EEG_allcond] =  LB3_prepro_pipeline(datapath, 'tinfBsl1s802.dat', 'getcon_tinf_eeg', 8, conditions2select, [-.6 1], [.1 30], [3 12], 1, 'GSN-HydroCel-129.sfp', 'HC1-128.ecfg', 1);

