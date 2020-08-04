function [sourceIntPol, segmri] = beamform_as(cfgas, data, plotflag)

% performs beamformer for specified parameters in cfg and in data
% as with all firldtrip functions, cfg is a structure array.
% cfgas.frequency -  integer: frequency for source analysis
% cfgas.method - letter string: one implemented method such as dics
% cfgas.path - path to structural mri
% cfgas.seg - structure variable with segmented mri if available
%
% data: structure array in fieldtrip format: needs to be freq domain data

haspath = 0;
hasmri = 0;
hassegmented = 0; 

if isfield(cfgas, 'path'), haspath = 1; end
if isfield(cfgas,'mri'), hasmri = 1; end
if isfield(cfgas,'seg'), hassegmented = 1; end

% first step: if no mri or segmented mri is given in cfg, 
% read (and segment) mr from path in cfg file

if haspath && ~hasmri && ~ hassegmented; 
    
    [mri] = read_fcdc_mri(cfgas.path);
    cfg = []; 
    cfg.segment = 'yes';
    cfg.smooth = 'no';
    cfg.template = '/Users/andreaskeil/matlab_as/spm5/templates/T1.nii';
    cfg.write = 'no';
    cfg.coordinates = 'spm';
    cfg.mriunits = 'mm';

    [segmri] = volumesegment_as(cfg, mri, cfgas.path);

    segmri.anatomy = mri.anatomy;

    
    clear mri
     
elseif hasmri & ~hassegmented
    
    cfg.segment = 'yes';
    cfg.smooth = 'no';
    cfg.template = '/Users/andreaskeil/matlab_as/spm5/templates/T1.nii'
    cfg.write = 'no';
    cfg.coordinates = 'spm'
    cfg.mriunits = 'mm'

    [segmri] = volumesegment_as(cfg, cfgas.mri, cfgas.path);

    segmri.anatomy = mri.anatomy;

    clear mri

elseif hassegmented
    segmri = cfgas.seg;
end


 % plot results if flag on

    if plotflag

        figure
        cfg = []
        cfg.interactive = 'yes'
        sourceplot(cfg,segmri);
        
        figure

        cfg.funparameter = 'gray';
        sourceplot(cfg,segmri)

        pause(1)

    end



%%%%%%% prepare the source space volume for single realistic shell
%%%%%%%%%%%%%%%

    cfg = []; 
    cfg.spheremesh = 4096; 
    
    [vol,cfg]=prepare_singleshell(cfg,segmri);

%%%%%%% load and align electrode layout
%%%%%%%%%%%%%%%    

%     if size(data.elec.pnt,1)> 130
%         load('/Users/andreaskeil/matlab_as/libas/4data/EGI257_fid.mat');
%         sensFid = EGI257_fid; 
%     else
%         load('/Users/andreaskeil/matlab_as/libas/4data/EGI129_fidNORM');
%         sensFid = EGI129_fidNORM;    
%     end
%     
   % disp('number of sensors plus fiducials:'), disp(size(sensFid,1)); 

    %plot the headmodel
    
    sensFid = data.elec
    
    if plotflag
        figure
        cfg = [];
        cfg.elec = sensFid; 
        cfg.vol = vol; 
        headmodelplot(cfg)
        
        pause(1)
    end
    
    
    
    % prepare the grid
    
    segmri= rmfield(segmri, 'csf')
    
    cfg.threshold = .1;
    cfg.tightgrid = 'yes';
    cfg.inwardshift = -1.5;
    cfg.mri = segmri;
    cfg.spheremesh = 8000; 
    template_grid = prepare_dipole_grid(cfg, vol, sensFid);
    
    
     % plot the headmodel plus grid
      if plotflag
     
         cfg = [];
        cfg.vol = vol;
        cfg.elec = sensFid;
        cfg.plotsensors = 'yes';
        figure
        headmodelplot(cfg);
        triplot(template_grid.pos(template_grid.inside,:), [], [], 'nodes')
        pause(1)
        
    end
    
%%%%%% forward solution 

    cfg = [];
    cfg.order = 10;
    
    % if the forward model is computed using the code from Guido Nolte, we
     % have to initialize the volume model using the gradiometer coil
     % locations
  if isfield(vol, 'type') && strcmp(vol.type, 'nolte')
     % compute the surface normals for each vertex point
         if ~isfield(vol.bnd, 'nrm')
              fprintf('computing surface normals\n');
              vol.bnd.nrm = normals(vol.bnd.pnt, vol.bnd.tri);
          end
    % estimate center and radius
    [center,radius]=sphfit([vol.bnd.pnt vol.bnd.nrm]);
    % initialize the forward calculation (only if gradiometer coils are available)
    if size(data.elec.pnt,1)>0 
      vol.forwpar = meg_ini([vol.bnd.pnt vol.bnd.nrm], center', cfg.order, [data.elec.pnt data.elec.pnt]);
    end
  end



%%%% leadfield %%%%%%%%

disp('computing leadfield')

  cfg.order = 10; 
  cfg.normalize = 'no';
  cfg.reducerank = 'no';
  
for i=1:length(template_grid.inside)
  % compute the leadfield on all grid positions inside the brain
  % progress(i/length(template_grid.inside), 'computing leadfield %d/%d\n', i, length(template_grid.inside));
  dipindx = template_grid.inside(i);
  template_grid.leadfield{dipindx} = compute_leadfield_as(template_grid.pos(dipindx,:), data.elec, vol, 'reducerank', cfg.reducerank, 'normalize', cfg.normalize);

  if isfield(cfg, 'grid') && isfield(cfg.grid, 'ori')
    % multiply with the normalized dipole moment to get the leadfield in the desired orientation
    template_grid.leadfield{dipindx} = grid.leadfield{dipindx} * grid.ori(dipindx,:)';
  end

end % for all grid locations inside the brain

template_grid.leadfield(template_grid.outside) = {nan};



%%%%%% source analysis 
%%%%%%%%%%%%%%%%%%%

disp('source analysis, assuming frequency domain data input:')
disp(cfgas.method)

    cfg = [];
    cfg.method       = cfgas.method; 
    cfg.projectnoise = 'yes';
    cfg.grid         = template_grid;
    cfg.vol          = vol;
    cfg.lambda       = 0;
    cfg.frequency = cfgas.frequency;
    source  = sourceanalysis(cfg,data);


    %%%% interpolate the sources
    cfg = [];
    cfg.downsample = 1;
    sourceIntPol = sourceinterpolate(cfg, source , segmri)
    for x = 1:240, sourceIntPol.anatomy(:,x,:) = flipud(squeeze(sourceIntPol.anatomy(:,x,:)));end
    %sourceIntPol = sourceinterpolate(cfg, source , cfgas.path); %this
    %works with elecs normed to original mri
    %sourceIntPol = sourceinterpolate(cfg, source , '/Users/andreaskeil/matlab_as/spm5/templates/T1.nii');
   
    
%%%%% plot the sources
    

    
    cfg = [];
    figure
    cfg.method = 'ortho';
    cfg.funparameter = 'avg.pow';
    cfg.interactive = 'yes';
    %cfg.funcolorlim = [-100 100];
    cfg.maskparameter = cfg.funparameter;
    cfg.opacitymap = 'rampup';
    
    sourceplot(cfg,sourceIntPol);
    
% for group averaging not forget to normalize volumes to the spm template: 
% cfg.template = '/Users/andreaskeil/matlab_as/spm5/templates/T1.nii'
% [mri] = read_fcdc_mri('s102.img.down.img');
% [interp_s102_ntr] = sourceinterpolate(cfgint, sourceIntPol, mri);




  