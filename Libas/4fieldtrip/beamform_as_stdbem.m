function [source,sensFid,norm_elec] = beamform_as_stdbem(cfgas, filemat, plotflag)

% reads mri, segments it if necessary, creates a source volume and matches the
% electrodes to the volume.
% 
% cfgas.vol  = bem model previously generated
% cfgas.path - path to structural mri
% 
% cfgas.warpflag - 1 if warping is needed, none or 0 if elec is already
% warped
% no elec file in cfgas !!!! this should be part of the data!!!
% ....then performs beamformer for specified parameters in cfg and in data
% as with all firldtrip functions, cfgas is a structure array.
% cfgas.frequency -  integer: frequency for source analysis
% cfgas.method - letter string: one implemented method such as dics
% cfgas.vol = standard vol
%cfgas.mri = standard mri
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
if ~isfield(cfgas, 'vol'), error('need volume first for this script..'), end

if isfield(cfgas, 'path'), haspath = 1; end
if isfield(cfgas,'mri'), hasmri = 1; end
if isfield(cfgas,'seg'), hassegmented = 1; end

% first step: if no mri or segmented mri is given in cfg, 
% read (and segment) mr from path in cfg file

if haspath && ~hasmri && ~ hassegmented; 
    
    [mri] = load(cfgas.path);
     
elseif hasmri & ~hassegmented
    
    mri = cfgas.mri; 
    

elseif hassegmented
    disp('segmented mri not needed here. info in vol'); 
end


 % plot results if flag on

    if plotflag

        figure
        cfg = []
        cfg.interactive = 'no'
        sourceplot(cfg,mri);
        
        pause(1)

    end



%%%%%%% prepare the head model? is already prepared interactively by BEMscript_as
%%%%%%%%%%%%%%%

    vol = cfgas.vol; 

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

   
%%%%%%%%%% % align the electrodes to invidual brain shape
    
if cfgas.warpflag
    % although orientation of source vol, mri and elec is matched
    % it is not correctly shown in the function below... thus, flipping vol
    % in y-axis direction
    vol4config = vol;
    
    %vol4config.bnd(1).pnt(:,2) = vol4config.bnd(1).pnt(:,2) .*-1; 
    cfg = []; 
    cfg.method = 'interactive'; 
    %cfg.method ='rigidbody'
    cfg.elec = data.elec;
    cfg.headshape = vol4config.bnd(1);
    
    [norm_elec] = electroderealign(cfg);
    
    sensFid = norm_elec; 
    
    data.elec = norm_elec; 
    
    save norm_elec.mat norm_elec
    
else
    load norm_elec.mat
    
    data.elec = norm_elec;
end
       
   

   
%%%% leadfield %%%%%%%%
  cfg = []; 
 cfg.vol   = vol;
 cfg.grid.resolution = 8;
 cfg.reducerank = 'no';
 %cfg.reducerank = 3
 cfg.normalize = 'no';
 cfg.normalizeparam = .5; 
 
 [grid] = prepare_leadfield(cfg, data);

save grid.mat grid

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
    data.elec = norm_elec;
%%%%%% source analysis 
%%%%%%%%%%%%%%%%%%%

disp('source analysis, assuming frequency domain data input:')
disp(cfgas.method)

    cfg = [];
    cfg.method       = cfgas.method; 
    cfg.projectnoise = 'yes';
    cfg.grid         = grid;
    cfg.vol          = vol;
    %cfg.lambda       = 0;
    cfg.frequency = cfgas.frequency;
    %cfg.refdip = [-15 -80 0]; 
    source  = sourceanalysis(cfg,data);

 % save the source file
      if isstruct(filemat)
      eval(['save ' deblank(filemat(index).name) '.pow.' num2str(cfgas.frequency) '.mat source -mat']) 
      else
      eval(['save ' deblank(filemat(index,:)) '.pow.' num2str(cfgas.frequency) '.mat source -mat'])
      end
 
   if plotflag
    %%%% interpolate the sources
    cfg = [];
    cfg.downsample =2;
    sourceIntPol = sourceinterpolate(cfg, source , mri)
    
  % check the dimensions ..!!!!!!!!! %%%%%% in the old days: for thepilips sysetm, the next line need to be uncommented, not for the siemesns
  % for x = 1:217, sourceIntPol.anatomy(:,x,:) = flipud(squeeze(sourceIntPol.anatomy(:,x,:)));end
 
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
    
   else
                source.avg.pow = source.avg.pow ./max(source.avg.pow);
                cfg = [];
                 cfg.downsample =2;
                 sourceIntPol = sourceinterpolate(cfg, source , mri)
                 figure(3)  
                cfg = [];
                cfg.method       = 'slice';
                cfg.funparameter = 'avg.pow';
                cfg.slicedim = 3
                sourceplot(cfg,sourceIntPol);
                pause(.5)
       
   end
    
end
