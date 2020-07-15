function [ outmat ] = reduceECOG3d( filemat, sensors)
%
for fileindex = 1: size(filemat,1);
    a = load(deblank(filemat(fileindex,:)));
    
    if length(sensors) ==1
    outmat = squeeze((a.WaPower(sensors, :, :))); 
    else
        outmat = squeeze(mean(a.WaPower(sensors, :, :))); 
    end
    
    contourf(outmat(200:end-100,:)'),caxis([0.8 1.2]), colorbar;
    title([deblank(filemat(fileindex,:))])
    pause, 
    	eval(['save ' deblank(filemat(fileindex,1:end-4)) '.best.mat outmat -mat']);
end 

