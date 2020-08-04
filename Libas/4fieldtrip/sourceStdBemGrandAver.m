function [sourceIntPol] = sourceStdBemGrandAver(sourcefilemat, mri, plotflag, outname)

if nargin < 4
    outname = []; 
end



% 

% source: output of beamform_as

    for index = 1:size(sourcefilemat,1); 
        
        if isstruct(sourcefilemat)
        filename = (sourcefilemat(index).name);
        else
        filename = (deblank(sourcefilemat(index,:)));
        end
  
      

        load(deblank(filename), '-mat'); 
     
        disp(deblank(filename)); 
    
   disp((max(source.avg.pow)))
   
   source.avg.pow = source.avg.pow ./ max(source.avg.pow); 
       
        if index == 1
            %%%% interpolate the sources
            cfg = [];
            cfg.downsample = 2;
            cfg.interpmethod = 'linear';
            sourceIntPol = sourceinterpolate(cfg, source , mri);
            
            powmat4d = zeros(size(sourceIntPol.avg.pow,1), size(sourceIntPol.avg.pow,2),...
                size(sourceIntPol.avg.pow,3), size(sourcefilemat,1));
            
            powmat4d(:,:,:,1) = sourceIntPol.avg.pow;
            
            if plotflag
                figure
                cfg = [];
                cfg.method       = 'slice';
                cfg.funparameter = 'avg.pow';
                cfg.slicedim = 3
                sourceplot(cfg,sourceIntPol);
                pause(2)
            end
  
           
        else
            cfg = [];
            cfg.downsample = 2 ;
            cfg.interpmethod = 'linear';
            sourceIntPol_2 = sourceinterpolate(cfg, source , mri);
            sourceIntPol.avg.pow = sourceIntPol.avg.pow+ sourceIntPol_2.avg.pow; 
            
            powmat4d(:,:,:,index) = sourceIntPol.avg.pow;
            
            if plotflag
                figure
                cfg = [];
                cfg.method       = 'slice';
                cfg.funparameter = 'avg.pow';
                cfg.slicedim = 3;
                sourceplot(cfg,sourceIntPol_2);
                pause(2)
            end
            
          
            end
           
        end
    
   
    average = mean(powmat4d,4);
   % sdmat_ttest = std(powmat4d,0,4) ./ sqrt(size(powmat4d,4));
   % ttestmat = average ./ sdmat_ttest; 
   
    sourceIntPol.avg.pow = average;
    
    %hist(max(sourceIntPol.avg.pow))
    %pause
    
    cfg = [];
    figure
    cfg.method = 'ortho';
    cfg.funparameter = 'avg.pow'; 
    cfg.interactive = 'yes';
    %cfg.funcolorlim = [3.6 8];
    cfg.maskparameter = cfg.funparameter;
    cfg.opacitymap = 'rampup';
    
    
    sourceplot(cfg,sourceIntPol);
    
    disp(['save ' outname ' sourceIntPol -mat'])
    
    eval(['save ' outname ' sourceIntPol -mat']); 
    
    
   
    
