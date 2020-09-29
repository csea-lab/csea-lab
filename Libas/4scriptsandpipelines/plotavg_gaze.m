% change this :-) 
CSlocation = 3
% now, need to know where the threat cues was
% on lab screen in 129 lab (CRS Display++: 1920 by 1080)
centerhori = 1920/2;
centerverti = 1080/2+20; 
radius = 120;
theta=linspace(0,2*pi,250); %you can increase this if this isn't enough yet
x=radius*cos(theta);
y=radius*sin(theta);
positions(1,:) = [centerhori centerverti]+[x(1) y(1)];
positions(2,:) = [centerhori centerverti]+[x(51) y(51)];
positions(3,:) = [centerhori centerverti]+[x(101) y(101)];
positions(4,:) = [centerhori centerverti]+[x(151) y(151)];
positions(5,:) = [centerhori centerverti]+[x(201) y(201)];

% calculate gaze density per screen area overall
Xbins  = 1:20:1920;
Ybins =  1:20:1080;


% habituation
for plotindex1 = 1:5
   figure(2), subplot(5,1,plotindex1), imagesc(Xbins(30:end-30), Ybins(18:end-18), squeeze(avgmat10(plotindex1,30:end-29, 18:end-17))'), hold on, 
   title(['habituation']), plot(positions(plotindex1,1), positions(plotindex1,2), 'm*'),  plot(centerhori, centerverti, '+k'), hold off
end


% acquisition
for plotindex1 = 6:10
   figure(3), subplot(5,1,plotindex1-5), imagesc(Xbins(30:end-30), Ybins(18:end-18), squeeze(avgmat10(plotindex1,30:end-29, 18:end-17))'), hold on, 
   title(['acquisition, CS+ = location: ' num2str(CSlocation)]), plot(positions(plotindex1-5,1), positions(plotindex1-5,2), 'm*'), ...
   plot(centerhori, centerverti, '+k')
   hold off
end
