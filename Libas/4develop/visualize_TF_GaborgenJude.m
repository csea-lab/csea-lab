function [] = visualize_TF_GaborgenJude(filemat, sensor2plot)

tempavg = zeros(1,4); 

for index1 = 1:size(filemat,1)

    temp = load(deblank(filemat(index1,:)));

    subplot(4,1,index1)

    contourf(squeeze(temp.WaPower(sensor2plot, :, :))'); clim([.1 .7]), colorbar

    pause(1)

    tempavg(index1) = squeeze(mean(mean(temp.WaPower(sensor2plot, 1300:1800, 6:12)))); 

end

figure, plot(tempavg)