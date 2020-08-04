function [source,sensFid,norm_elec, segmri] = beamform_as_pow(cfgas, filemat, plotflag)

% reads mri, segments it if necessary, creates a source volume and matches the
% electrodes to the volume.
% 
% cfgas.path - path to structural mri
% cfgas.seg - structure variable with segmented mri if available
% cfgas.mri - mri that has been read in already
% cfgas.warpflag - 1 if warping is needed, none or 0 if elec is already
% warped
% no elec file in cfgas !!!! this should be part of the data!!!
% ....then performs beamformer for specified parameters in cfg and in data
% as with all firldtrip functions, cfgas is a structure array.
% cfgas.frequency -  integer: frequency for source analysis
% cfgas.method - letter string: one implemented method such as dics
% filemat: matrix with filenames that lead to mat files, which should contain a strcuture array "freq"
% structure array must be in fieldtrip format: needs to be freq domain data

if isstruct(filemat)
    load(filemat(1).name, '-mat')
else
load (deblank(filemat(1,:)), '-mat')
end
data = freq;

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
    
    mri = cfgas.mri; 
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
        ft_sourceplot(cfg,segmri);
        
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

%%%%%%% load electrode layout
%%%%%%%%%%%%%%%    
%    
%     if size(data.elec.pnt,1)> 130
%         load('/Users/andreaskeil/matlab_as/libas/4data/EGI257_fid.mat');
%         sensFid = EGI257_fid; 
%     else
%         load('/Users/andreaskeil/matlab_as/libas/4data/EGI129_fidNORM');
%         sensFid = EGI129_fidNORM;    
%     end
    
disp('')
disp('sensors:')
sensFid = data.elec;

    %plot the headmodel
    
    
    


%%%%%

cfg = [];
cfg.smooth = 8;
cfg.resolution4mri = .4
cfg.threshold = .15;
cfg.tightgrid = 'yes';
cfg.inwardshift = 0;
cfg.mri = segmri;
%cfg.spheremesh = 8000; 
template_grid = prepare_dipole_grid(cfg, vol, sensFid);
    
    
%%%%%%%%%% % align the electrodes to invidual brain shape
    
if cfgas.warpflag
    
    cfg = []; 
    cfg.method = 'interactive'; 
    cfg.elec = data.elec;
    cfg.headshape = vol.bnd;
    
    [norm_elec] = electroderealign(cfg);
    
    sensFid = norm_elec; 
    
    data.elec = norm_elec; 
    
    save norm_elec.mat norm_elec
    
else
    load norm_elec.mat
    
    data.elec = norm_elec;
end
       
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



%from here it is possible to do multiple files, if they come form the same subject

for index = 1:size(filemat,1)
    
    if isstruct(filemat)   
    load(filemat(index).name, '-mat')
    deblank(filemat(index).name)
    else
    load(deblank(filemat(index,:)),'-mat')
    deblank(filemat(index,:))
    end
    
    data = freq;
    data.elec = sensFid;
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
    cfg.refdip = [-15 -80 0]; 
    source  = sourceanalysis_as(cfg,data);

 % save the source file
      if isstruct(filemat)
      eval(['save ' deblank(filemat(index).name) '.pow.mat source -mat']) 
      else
      eval(['save ' deblank(filemat(index,:)) '.pow.mat source -mat'])
      end
 
   if plotflag
    %%%% interpolate the sources
    cfg = [];
    cfg.downsample = 1;
    sourceIntPol = sourceinterpolate(cfg, source , segmri)
    
  % check the dimensions ..!!!!!!!!! %%%%%% in the old days: for thepilips sysetm, the next line need to be uncommented, not for the siemesns
  % for x = 1:240, sourceIntPol.anatomy(:,x,:) = flipud(squeeze(sourceIntPol.anatomy(:,x,:)));end
   
    
    %sourceIntPol = sourceinterpolate(cfg, source , cfgas.path); %this
    %works with elecs normed to original mri
    %sourceIntPol = sourceinterpolate(cfg, source , '/Users/andreaskeil/matlab_as/spm5/templates/T1.nii');
   
    
  
   %%%%% plot the sources
    
    cfg = [];
    figure
    cfg.method = 'ortho';
    cfg.funparameter = 'avg.pow';
    cfg.interactive = 'yes';
    %cfg.funcolorlim = [-100 3000];
    cfg.maskparameter = cfg.funparameter;
    cfg.opacitymap = 'rampup';
    
    sourceplot(cfg,sourceIntPol);
   end
    
end
