%beamformscript_as

% first read structural 


spm

% -> dicom import, creates *.img file

[mri] = read_fcdc_mri('s888_-0501-00005-000001-01.img');

cfg.segment = 'yes';
cfg.smooth = 'no';
cfg.template = '/Users/andreaskeil/matlab_as/spm5/templates/T1.nii'
cfg.write = 'no';
cfg.coordinates = 'spm'
cfg.mriunits = 'mm'

[segment] = volumesegment_as(cfg, mri, 's888_-0501-00005-000001-01.img')

segment.anatomy = mri.anatomy;

clear mri

% plot results 

cfg = []
cfg.interactive = 'yes'
sourceplot(cfg,segment)

cfg.funparameter = 'gray';
sourceplot(cfg,segment)


%data in frequency domain: 

cfg = [];
cfg.output = 'powandcsd';
cfg.tapsmofrq = .3;
cfg.foilim     = [1 15];
cfg.method = 'mtmfft';
[result_freq] = freqanalysis(cfg, data_in);



    % prepare the source space volume for single shell

    cfg = [];
    cfg.spheremesh = 4096
    [vol,cfg]=prepare_singleshell(cfg,segment);
    
    %alternatively
    % prepare_dipole_grid

    %alternatively
    %prepare_bemmodel_as

    % load sensors

    sens = read_fcdc_elec('GSN257.sfp');


    %plot the headmodel

    cfg.elec = sens; 
    cfg.vol = vol; 
    headmodelplot(cfg)

    %prepare the leadfield for this volume using hauk compute_lfdmat.m

   cfg = []
   cfg.elec = sens; 
    
   [grid, cfg] = prepare_leadfield_as(cfg, vol) 
    
    
   % source analysis: 
   
   % need data file with covariance matrix
   
   data = scads2fieldtrip('sn_02.fl40.E1.at1.ar', sens);
   data.datatype = 'timelock'
   data.cov = cov(data.avg');
   
   % source analysis proper
   cfg = []
   cfg.grid = grid;
   cfg.grid.inside = [1:4096];
   cfg.grid.outside =[]; 
   cfg.grid.xgrid      = [-7.5:7.5]
   cfg.grid.ygrid      = [-7.5:7.5]
   cfg.grid.zgrid      = [-7.5:7.5]
   cfg.grid.dim = [16 16 16]
   cfg.vol = vol;
   cfg.method = 'lcmv'
   cfg.elec = sens;
   cfg.vol = vol; 
   
   
   [source] = sourceanalysis(cfg, data);
   
    cfg = [];
    cfg.downsample = 1;
    sourceIntPol = sourceinterpolate(cfg, source , 's888_-0501-00005-000001-01.img');
   
    cfg = [];
    cfg.method = 'slice';
    cfg.funparameter = 'avg.pow';
    sourceplot(cfg,sourceIntPol);

    cfg = [];
    cfg.method = 'ortho';
    cfg.funparameter = 'avg.pow';
    cfg.interactive = 'yes';
    cfg.maskparameter = cfg.funparameter;cfg.opacitymap = 'rampup';
    sourceplot(cfg,sourceIntPol);
   
    fg = [];
    cfg.method = 'surface';
    cfg.funparameter = 'avg.pow';
    cfg.maskparameter = cfg.funparameter;
    cfg.opacitymap = 'rampup';  
    cfg.projmethod = 'nearest'; 
    cfg.surffile = 'surface_l4_both.mat';
    cfg.surfdownsample = 10; 

    sourceplot(cfg,sourceDiffIntN);
    view ([90 0])
    
    
    

% prepare the source space volume for BEM model
% construct a segmentation of the brain compartment
brain = (segment.gray>0.5 | segment.white>0.5);
s = strel('disk', 5);
brain = imclose(brain, s);
% brain = imopen(brain, s);
brain = imdilate(brain, strel('disk', 2));
brain = imfill(brain, 'holes');

volplot(brain .* mri.anatomy)

% construct a segmentation of the skin compartment

skin = (mri.anatomy < 30);
s = strel('disk', 5);
skin = imclose(skin, s);
skin(:,:,1) = 1;
skin = imdilate(skin, strel('disk', 2));
skin = imfill(skin, 'holes');
skin(:,:,1) = 0;

volplot(skin .* mri.anatomy)

% construct a segmentation of the skull compartment
s = strel('disk', 5);
skin_a  = imerode(skin, s);
brain_a = imdilate(brain, s);
skull = (brain_a & skin_a);

volplot(skull .* mri.anatomy)   
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %OR: 
    
    % try and prepare BEM from this volume
    cfg.tissue         = [1]
    cfg.numvertices    =  1
    cfg.conductivity   =  1
    cfg.isolatedsource =  0
    cfg.method         =  'brainstorm'
    

    %define config
    cfg                       = [];
    cfg.elec = sens;
    cfg.vol                   = vol;
    cfg.resolution            = 1;
    cfg.reducerank            = 2;
    cfg.xgrid                 = 'auto';
    cfg.ygrid                 = 'auto';
    cfg.zgrid                 = 'auto';

    [grid]                    = prepare_leadfield(cfg);
