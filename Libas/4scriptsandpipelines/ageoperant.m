% script for age_operant

%%
figure
filename = 'ForSas_OC_LossOLDER_Only_10FEB17_WIDE.csv';
M1 = csvread(filename, 1, 1);
M1 = movmean(M1, 3, 2); 
% corrects for rotation to other side, difference cannot exceed 90 degrees
M1(M1>90) = 180-M1(M1>90);
M1 = (90-M1)./90; % expresses as correct responses relative to 1 (best) and zero (worst)
% plot(mean(M1), 'r'),
grandmeanM1 = mean(M1); 
M1(1,:) = M1(1,:).*-1 + 1;
M1(17,:) = grandmeanM1;
M1(26,:) = grandmeanM1;
[parametersM1, mseM1] = modweibullm(M1, grandmeanM1, 1);
index = parametersM1(:,2) > 5; 
parametersM1(index, 2) = 4.89; 
%%
filename = 'ForSas_OC_GainOLDER_Only_10FEB17_WIDE.csv';
M2 = csvread(filename, 1, 1);
M2 = movmean(M2, 3, 2); 
% corrects for rotation to other side, difference cannot exceed 90 degrees
M2(M2>90) = 180-M2(M2>90);
M2 = (90-M2)./90; % expresses as correct responses relative to 1 (best) and zero (worst)
%plot(mean(M2), 'k'), hold on
grandmeanM2 = mean(M2); 
M2(26,:) = grandmeanM2;
[parametersM2, mseM2] = modweibullm(M2, grandmeanM2, 1);
index = parametersM2(:,2) > 5; 
parametersM2(index, 2) = 4.89; 
%%
filename = 'ForSas_OC_LossYOUNGER_Only_10FEB17_WIDE.csv';
M3 = csvread(filename, 1, 1);
M3 = movmean(M3, 3, 2); 
% corrects for rotation to other side, difference cannot exceed 90 degrees
M3(M3>90) = 180-M3(M3>90);
M3 = (90-M3)./90; % expresses as correct responses relative to 1 (best) and zero (worst)
%plot(mean(M3), 'r--'), hold on
grandmeanM3 = mean(M3); 
[parametersM3, mseM3] = modweibullm(M3, grandmeanM3, 1);
index = parametersM3(:,2) > 5; 
parametersM3(index, 2) = 4.89; 
%%
filename = 'ForSas_OC_GainYOUNGER_Only_10FEB17_WIDE.csv';
M4 = csvread(filename, 1, 1);
M4 = movmean(M4, 3, 2); 
% corrects for rotation to other side, difference cannot exceed 90 degrees
M4(M4>90) = 180-M4(M4>90)
M4 = (90-M4)./90; % expresses as correct responses relative to 1 (best) and zero (worst)
%plot(mean(M4), 'k--'), hold on
grandmeanM4 = mean(M4); 
[parametersM4, mseM4] = modweibullm(M4, grandmeanM4, 1);
index = parametersM4(:,2) > 5; 
parametersM4(index, 2) = 4.89; 
%%
plot(mean(M1), 'r'),hold on
plot(mean(M2), 'k'), hold on
plot(mean(M3), 'r--'), hold on
plot(mean(M4), 'k--'), hold on
legend('olderloss', 'oldergain', 'youngerloss', 'youngergain')
%%
statmat = [ parametersM1 parametersM2; parametersM3 parametersM4];

