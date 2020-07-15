% script cross-correlation analysis AK
template = mean(lrp(:, :, :), 3);
template = mean(template, 1);
template = template(1:681);

% for response locked LRP
for sub = 1:46;
C = xcorr(template, squeeze(lrp(2,1:681,sub)), 'coeff'); index = find(C == max(C(640:720)))
timecon2(sub)= (681-index).*2.5 -90; figure, subplot(2,1,2), plot(C)
subplot(2,1,1), title(num2str(timecon2(sub)))
hold on
plot(template .*400, 'r')
plot(squeeze(lrp(2,1:681,sub)) .*400, 'k'), pause(1)
hold off
end


% for stim locked LRP
%for sub = 1:46;
%C = xcorr(template, squeeze(lrp(1,1:681,sub))); index = find(C == max(C(640:720)))
%timecon1(sub)= (681-index).*2.5 +265; figure, subplot(2,1,2), plot(C)
%subplot(2,1,1), title(num2str(timecon1(sub)))
%hold on
%plot(template .*400, 'r')
%plot(squeeze(lrp(1,1:681,sub)) .*400, 'k'), pause
%hold off
%end

outmat = [timecon1' timecon2'];
diff = [timecon1- timecon2]';