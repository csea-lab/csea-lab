% script for olfaxis wavelet

sensorvec = {'Cz'; 'Oz'; 'O2'; 'O1'; 'Fp2'; 'Fp1'; 'F4'; 'F3'; 'C4'; 'C3'; 'P4'; 'P3'; 'F8'; 'F7'; 'RN'; 'LN'};

[WaPower, PLI, PLIdiff] = wavelet_app_matfiles('G18.data3d.mat', fs, 7, 81, 2, []);

faxisall = 0:0.5:100;

faxis = faxisall(7:2:81)

taxis = -.4:1/fs:1.6;

WaPowerBsl = bslcorrWAMat_percent(WaPower, 1200:2200);

for sensor = 1:16
contourf(taxis(600:end-1200), faxis(1:25), squeeze(WaPowerBsl(sensor, 600:11008,  1:25))', 14), colorbar, 
title(sensorvec(sensor)), pause
end
