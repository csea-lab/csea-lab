function [histdata_out] = plotgazedata(matfile, datfile)
% extracts gaze data from correct eyeout.mat files and computes gaze
% locations relative to threat cue
% plots gaze density and writes out the density for the 10 conditions, in
% order 11 12 13 14 15 21 22 23 24 25
% saves the file as gazehist10.mat
% for wavelets use wavelet_gaze function

% eye gaze data first (matfiles)
temp = load(matfile); 
data = temp.eyelinkout.matcorr; 
data = data(1:2,501:1500, : ); % no puli, only gaze; only time points during stim on period

% now, need to know where the threat cues was
% on lab screen in 129 lab (CRS Display++: 1920 by 1080)
centerhori = 1920/2;
centerverti = 1080/2; 
radius = 120;
theta=linspace(0,2*pi,250); %you can increase this if this isn't enough yet
x=radius*cos(theta);
y=radius*sin(theta);
positions(1,:) = [centerhori centerverti]+[x(1) y(1)];
positions(2,:) = [centerhori centerverti]+[x(51) y(51)];
positions(3,:) = [centerhori centerverti]+[x(101) y(101)];
positions(4,:) = [centerhori centerverti]+[x(151) y(151)];
positions(5,:) = [centerhori centerverti]+[x(201) y(201)];

% conditions next
aha = dlmread(datfile); 
conditions = aha(1:350, 5)+[ones(150,1).*10; ones(200,1).*20];
CSlocation = aha(1,6); 
condivec = unique(conditions);

% calculate gaze density per screen area overall
Xbins  = 1:20:1920;
Ybins =  1:20:1080;

h = histogram2(data(1,:,:), data(2,:,:), Xbins , Ybins);
histdata = h.Values; 
figure(101)
imagesc(Xbins(1:end-1), Ybins(1:end-1), histdata'), hold on, plot(positions(CSlocation,1), positions(CSlocation,2), 'r*'), hold off

for con_index = 1:5
data_hab(:, :, :, con_index) = data(:, :, conditions(conditions==condivec(con_index))); 
end

for con_index = 6:10
data_acq(:, :, :, con_index) = data(:, :, conditions(conditions==condivec(con_index))); 
end

% calculate density for conditions and plot across whole screen:
% habituation
for plotindex1 = 1:5
   figure(1), subplot(5,1,plotindex1), h = histogram2(data_hab(1,:,:, plotindex1), data_hab(2,:,:, plotindex1), Xbins , Ybins); title('habituation')
    histdata = h.Values; 
    histdata_out(plotindex1, :, :) = histdata; 
   figure(2), subplot(5,1,plotindex1), imagesc(Xbins(1:end-1), Ybins(1:end-1), histdata'), hold on, 
   title(['habituation']), plot(positions(CSlocation,1), positions(CSlocation,2), 'r*'), hold off
end

% calculate density for conditions and plot across whole screen: 
% acqusition
for plotindex1 = 6:10
   figure(3), subplot(5,1,plotindex1-5), h = histogram2(data_acq(1,:,:, plotindex1), data_acq(2,:,:, plotindex1), Xbins , Ybins); title('acquisition')
    histdata = h.Values; 
    histdata_out(plotindex1, :, :) = histdata; 
   figure(4), subplot(5,1,plotindex1-5), imagesc(Xbins(1:end-1), Ybins(1:end-1), histdata'), hold on, 
   title(['acquisition, CS+ = location: ' num2str(CSlocation)]), plot(positions(CSlocation,1), positions(CSlocation,2), 'r*'), hold off
end

% do it again, zoomed in to see any tendency to look at CS+
for plotindex1 = 6:10
   figure(99), h = histogram2(data_acq(1,:,:, plotindex1), data_acq(2,:,:, plotindex1), Xbins , Ybins); title('acquisition')
    histdata = h.Values; 
   figure(5), subplot(5,1,plotindex1-5), imagesc(Xbins(30:end-30), Ybins(18:end-18), histdata(30:end-31, 18:end-19)'), hold on, 
   title(['acquisition, CS+ = location: ' num2str(CSlocation)]), plot(positions(CSlocation,1), positions(CSlocation,2), 'r*'), hold off
end


% save output: gaze density for each condition
eval(['save ' datfile '.gazehist10.mat histdata_out -mat'])


% % trial wise plotting if needed
% for trial = 1:350
%     
%     plot(squeeze(data(1,:, trial)), squeeze(data(2,:, trial))), axis([1 1960 1 1200]), 
%     title(['trial: ' num2str(trial)])
%     pause
%         
% end

