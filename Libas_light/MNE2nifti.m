function [normalised] = MNE2nifti(filemat)


load source4MNE
load MNE2nifti_indices.mat

MRI= ft_read_mri('/Users/andreaskeil/SUMAVIEW/TT_N27align.nii');

for fileindex = 1: size(filemat,1)
    
    filename = deblank(filemat(fileindex,:)); 

    source4MNE.avg.pow(source4MNE.avg.pow>0.01) = 0.01; 

    data350 = ReadAvgFile(filename);

    data350(250:end) = 0.001; % get rid of the data in the neck

    data_at_indexmat = repmat(data350, 1, 30); 

    source4MNE.avg.pow(mat2vec(MNE2nifti_indices)) = mat2vec(data_at_indexmat); 

    cfg.parameter = 'avg.pow';
    sourceIntPol = ft_sourceinterpolate(cfg, source4MNE , MRI);
    sourceIntPol.coordsys = 'acpc';

    
cfg = []; 
    cfg.parameter = 'pow';
    cfg.write = 'no';
    cfg.spmversion = 'spm12';
    cfg.template = '/Users/andreaskeil/matlab_as/spm12/canonical/avg152T1.nii'
    [normalised1] = ft_volumenormalise(cfg, sourceIntPol);
    normalised1.pow(:, :, 1:35) = 0; 

    cfg = []; 
    cfg.parameter = 'pow';
    cfg.write = 'no';
    cfg.spmversion = 'spm12';
    cfg.template = '/Users/andreaskeil/SUMAVIEW/TT_N27align.nii'
    [normalised2] = ft_volumenormalise(cfg, sourceIntPol);
    normalised2.pow(:, :, 1:35) = 0; 
    
% plot the afni version
cfg = [];
    cfg.method = 'ortho';
    cfg.funparameter = 'avg.pow';
    cfg.interactive = 'yes';
    %cfg.funcolorlim = [0 4];
    cfg.maskparameter = cfg.funparameter;
    cfg.opacitymap = 'rampup';
    
    ft_sourceplot(cfg,normalised2);
  
% save for afni or SPM/MRIcron
cfgexp.scaling = 'no';
cfgexp.filename = ['afni_' (filename(1:strfind(filename, '.')-1))];
cfgexp.coordinates = 'spm';
cfgexp.datatype = 'float';
cfgexp.parameter = 'pow'
cfgexp.filetype = 'nifti';
ft_volumewrite(cfgexp, normalised2)

% cfgexp.scaling = 'no';
% cfgexp.filename = ['SPM_' (filename(1:strfind(filename, '.')-1))];
% cfgexp.coordinates = 'spm';
% cfgexp.datatype = 'float';
% cfgexp.parameter = 'pow'
% cfgexp.filetype = 'nifti';
% ft_volumewrite(cfgexp, normalised1)


end
