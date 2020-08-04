function [sourceDiff] = sourcediff_as_coh(sourcefile1, sourcefile2, mri)

% reads 2 sources, forms difference and interpolates on mri

    sourceroh1 = load(deblank(sourcefile1), '-mat'); 
    sourceroh2 = load(deblank(sourcefile2), '-mat'); 

% source: output of beamform_as
source1 = sourceroh1.GMsourceDiff;
source2 = sourceroh2.GMsourceDiff;

sourceDiff = source2;

sourceDiff.avg.coh = (source2.avg.coh - source1.avg.coh)

%sourceDiff.avg.pow = (source2.avg.pow - source1.avg.pow)  ./ sqrt(source2.avg.pow + source1.avg.pow);

%sourceDiff.avg.pow = (source2.avg.pow - source1.avg.pow)  ./ (source2.avg.pow + source1.avg.pow);

%sourceDiff.avg.pow = (source2.avg.pow - source1.avg.pow) ./ (source1.avg.pow);

%sourceDiff.avg.pow = (source2.avg.pow ./ source1.avg.pow);


    %%%% interpolate the sources
    cfg = [];
    cfg.downsample = 2;
    sourceIntPol = sourceinterpolate(cfg, sourceDiff , mri)
    
% !!!!!!!!! %%%%%% for thepilips sysetm, the next line need to be uncommented, not for the siemesns
   % for x = 1:240, sourceIntPol.anatomy(:,x,:) = flipud(squeeze(sourceIntPol.anatomy(:,x,:))); 
    
    %sourceIntPol = sourceinterpolate(cfg, source , cfgas.path); %this
    %works with elecs normed to original mri
    %sourceIntPol = sourceinterpolate(cfg, source , '/Users/andreaskeil/matlab_as/spm5/templates/T1.nii');
   
    
%%%%% plot the sources
    
    cfg = [];
    figure
    cfg.method = 'ortho';
    cfg.funparameter = 'avg.pow';
    cfg.interactive = 'yes';
    cfg.funcolorlim = [-5 5];
    cfg.maskparameter = cfg.funparameter;
    cfg.opacitymap = 'rampup';
    
    sourceplot(cfg,sourceIntPol);
