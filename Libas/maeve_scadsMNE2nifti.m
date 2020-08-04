
% find nearest points brain volume relative to our minimum norm shell
clear tempvec; 
clear indexmat;

load mneshell_new.mat
load source4MNE
load GMchosenones_segMRI.mat 

source4MNE.avg.pow(source4MNE.avg.pow>0.01) = 0.01; 

for shellindex = 1:350
    for sourceindex = 1:52360 
        if ismember(sourceindex, source4MNE.inside);
        tempvec(sourceindex) = norm(mneshell_new(shellindex,:)-source4MNE.pos(sourceindex,:));
        else
         tempvec(sourceindex) = 999; 
        end
    end   
     if shellindex/50 == round(shellindex/50), fprintf('.'), end
   [dummy, indexmat(shellindex,:)] = mink(tempvec,30);
end

data350 = ReadAvgFile('Fgabors.at');

data_at_indexmat = repmat(data350, 1, 20); 

source4MNE.avg.pow(mat2vec(indexmat)) = mat2vec(data_at_indexmat); 

cfg.parameter = 'avg.pow';
sourceIntPol = ft_sourceinterpolate(cfg, source4MNE , segmri);

 cfg = [];
    figure
    cfg.method = 'ortho';
    cfg.funparameter = 'avg.pow';
    cfg.interactive = 'yes';
    %cfg.funcolorlim = [0 4];
    cfg.maskparameter = cfg.funparameter;
    cfg.opacitymap = 'rampup';
    
    ft_sourceplot(cfg,sourceIntPol);
    

cfgexp.scaling = 'no';
cfgexp.filename = 'test2'
cfgexp.coordinates = 'spm';
cfgexp.datatype = 'float';
cfgexp.parameter = 'pow'
cfgexp.filetype = 'nifti'
ft_volumewrite(cfgexp, sourceIntPol)

