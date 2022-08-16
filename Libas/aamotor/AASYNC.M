% erzeugt vektor mit frequenz des metronoms aus useac-Exp
% korreliert emp. daten mit metronom-beat
% bed. zuvor lief aastart

clear mithand
clear mitbic
clear mithand




t=(0:.1:length(tid))';
metro=sin(2*pi*0.333*t);


figure(2)

subplot (4,1,1)
plot (t,metro)
title('metronome beat')

subplot (4,1,2)
plot (tid,akt2(tid))
title ('actograph')

subplot (4,1,3)
plot (tid,uni2(tid))
title ('biceps EMG')

subplot (4,1,4)
plot (tid,uni3(tid))
title('lower arm EMG')

% Korr für unerschiedliche Lags


meint = metro(1:10:length(metro));

for lag = 1 : 7;

  N = meint(1:length(tid)-lag);
  
  akto1 = akt2(min(tid)+lag : max(tid));
  EMG1 = uni2(min(tid)+lag : max(tid));
  EMG2 = uni3(min(tid)+lag : max(tid));

f1 = corrcoef(N,akto1);

f2 = corrcoef(N,EMG1);

f3 = corrcoef(N,EMG2);

mitakt(lag) = f1(2,1);

mitbic(lag) = f2(2,1);

mithand(lag) = f3(2,1);

end

mitakt
mitbic
mithand