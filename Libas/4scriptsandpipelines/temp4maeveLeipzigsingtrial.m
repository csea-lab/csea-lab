att = attended;
ign = distractor;

for x = 1:24
figure(1), plot(squeeze(att(:,x, 1))), hold on, plot(squeeze(ign(:,x, 1)), 'r'), pause(.1), end
for x = 1:24
figure(2), plot(squeeze(att(:,x, 2))), hold on, plot(squeeze(ign(:,x, 2)), 'r'), pause(.1), end
for x = 1:24
figure(3), plot(squeeze(att(:,x, 3))), hold on, plot(squeeze(ign(:,x, 3)), 'r'), pause(.1), end
for x = 1:24
figure(4), plot(squeeze(att(:,x, 4))), hold on, plot(squeeze(ign(:,x, 4)), 'r'), pause(.1), end

%%
%combine into one mat for z-transform
bothmat1 = []; 
for x = 1:24
temp = (z_norm([squeeze(att(:,x, 1)); squeeze(ign(:,x, 1))]));
%temp = (([squeeze(att(:,x, 1)); squeeze(ign(:,x, 1))]));
sub = temp(1:32)
sub(sub<-1.5) = nan;
temp = [(sub(1:32)); (temp(33:end))]
plot(temp), pause, 
bothmat1(x,:) = [nanmean(temp(1:32)) nanmean(temp(33:end))]; 
end
[dum,dum1,dum2,stats] = ttest(bothmat1(:, 1), bothmat1(:,2))

%%
%combine into one mat for z-transform
bothmat2 = [];  
for x = 1:24
temp = (z_norm([squeeze(att(:,x, 2)); squeeze(ign(:,x, 2))]));
%temp = (([squeeze(att(:,x, 1)); squeeze(ign(:,x, 1))]));
sub = temp(1:32)
sub(sub<-1.2) = nan; 
temp = [(sub(1:32)); (temp(33:end))]
plot(temp), pause, 
bothmat2(x,:) = [nanmean(temp(1:32)) nanmean(temp(33:end))]; 
end
[dum,dum1,dum2,stats] = ttest(bothmat2(:, 1), bothmat2(:,2))
%%
att1 = bothmat1(:,1)-bothmat1(:,2)
att2 = bothmat2(:,1)-bothmat2(:,2)
[dum,dum1,dum2,stats] = ttest((att1+att2)./2)
%%
%%%combine into one mat for z-transform
bothmat3 = []; 
for x = 1:24
temp = (z_norm([squeeze(att(:,x, 3)); squeeze(ign(:,x, 3))]));
%temp = (([squeeze(att(:,x, 1)); squeeze(ign(:,x, 1))]));
sub = temp(1:32)
sub(sub<-1.5) = nan;
temp = [(sub(1:32)); (temp(33:end))]
plot(temp), pause, 
bothmat3(x,:) = [nanmean(temp(1:32)) nanmean(temp(33:end))]; 
end
[dum,dum1,dum2,stats] = ttest(bothmat3(:, 1), bothmat3(:,2))

%%
%combine into one mat for z-transform
bothmat4 = [];   
for x = 1:24
temp = (z_norm([squeeze(att(:,x, 4)); squeeze(ign(:,x, 4))]));
%temp = (([squeeze(att(:,x, 1)); squeeze(ign(:,x, 1))]));
sub = temp(1:32)
sub(sub<-1.2) = nan; 
temp = [(sub(1:32)); (temp(33:end))]
plot(temp), pause, 
bothmat4(x,:) = [nanmean(temp(1:32)) nanmean(temp(33:end))]; 
end
[dum,dum1,dum2,stats] = ttest(bothmat4(:, 1), bothmat4(:,2))
%%
att3 = bothmat3(:,1)-bothmat3(:,2)
att4 = bothmat4(:,1)-bothmat4(:,2)
[dum,dum1,dum2,stats] = ttest((att3+att4)./2)
