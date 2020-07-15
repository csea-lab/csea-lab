function [ EEG ] = arash_prepro2( EEG, componentsremove )
%U

EEG = pop_subcomp( EEG, componentsremove, 0);

[ outmat1, badindex ] = scadsAK_3dtrials(EEG.data);

EEG.event(badindex) = [];
EEG.trials = size(outmat1,3);
EEG.data = single(outmat1); 

outmat3d_aftertrial = EEG.data;

outmat3d_aftertrialAR = avg_ref_add3d(outmat3d_aftertrial); 

EEG.data = outmat3d_aftertrialAR; 






