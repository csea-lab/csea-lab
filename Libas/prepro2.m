function [ EEG ] = prepro2( EEG, componentsremove , EEGfilepath)
%


EEG = pop_subcomp( EEG, componentsremove, 0);

[ outmat1, badindex ] = scadsAK_3dtrials(EEG.data);

badindex
size(outmat1)

EEG.event(badindex) = [];
EEG.epoch(badindex) = [];

size(EEG.event)

EEG.trials = size(outmat1,3);
EEG.data = single(outmat1); 

outmat3d_aftertrial = EEG.data;

outmat3d_aftertrialAR = avg_ref_add3d(outmat3d_aftertrial); 

EEG.data = outmat3d_aftertrialAR; 

EEG = pop_saveset( EEG, 'filename',[EEGfilepath '.final.set'],'filepath',pwd);








