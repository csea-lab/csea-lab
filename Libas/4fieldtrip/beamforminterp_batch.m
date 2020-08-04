%beamforminterp_batch
% reads source from individual solution, the individual mr, a template MR
% passes everything on to source2norm4Gavg_as and saves the results...
function[] = beamforminterp_batch(directory, indiv_MR_path, template_path)

cd (directory)

[indiv_mri] = read_fcdc_mri(indiv_MR_path);
template_mri = read_fcdc_mri(template_path);

load source_neutral.mat

[interp_norm_ntr] = source2norm4Gavg_as(source_2, indiv_mri, template_mri)


cfg = [];
figure
cfg.method = 'ortho';
cfg.funparameter = 'avg.pow';
cfg.interactive = 'yes';
cfg.maskparameter = cfg.funparameter;
cfg.opacitymap = 'rampup';
sourceplot(cfg,interp_norm_ntr);

save interp_norm_ntr.mat interp_norm_ntr -mat
clear interp_norm_ntr

%%%%%%

load source_pleasant.mat

[interp_norm_pleas] = source2norm4Gavg_as(source_1, indiv_mri, template_mri)


cfg = [];
figure
cfg.method = 'ortho';
cfg.funparameter = 'avg.pow';
cfg.interactive = 'yes';
cfg.maskparameter = cfg.funparameter;
cfg.opacitymap = 'rampup';
sourceplot(cfg,interp_norm_pleas);

save interp_norm_pleas.mat interp_norm_pleas -mat
clear interp_norm_pleas

%%%%%%%%


load source_unpleasant.mat

[interp_norm_upl] = source2norm4Gavg_as(source_3, indiv_mri, template_mri)


cfg = [];
figure
cfg.method = 'ortho';
cfg.funparameter = 'avg.pow';
cfg.interactive = 'yes';
cfg.maskparameter = cfg.funparameter;
cfg.opacitymap = 'rampup';
sourceplot(cfg,interp_norm_upl);

save interp_norm_upl.mat interp_norm_upl -mat
clear interp_norm_upl