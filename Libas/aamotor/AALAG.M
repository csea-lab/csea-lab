% berechnet maximalen corrcoef für unterschiedliche Time-lags
% Voraussetzung : zuvor lief aastart.m

clear ergebnis
clear EMG
clear akto

disp(' ')
disp ('MAXIMALES R FÜR UNTERSCHIEDILCHE TIME-LAGS:')
weite = 3;  

for lag = 0 : weite

count = min (tid):(max(tid)-lag);
bount = min (tid)+lag: max(tid);


     akto(count)= akt2(count);
     EMG(count)= uni3(bount);
     EMG1(count)=uni2(bount);

erg = corrcoef (akto(count),EMG(count));
erg2= corrcoef (akto(count),EMG1(count));
ergebnis(lag+1) = erg(1,2);
ergebnis2(lag+1)= erg2(1,2);
end

ergebnis
fprintf ('maximale Korrelation Unterarm-EMG mit Aktometer für alle time-lags zwischen 0 und 5\n')
fprintf ('beträgt_____________________________%g  \n',max(ergebnis))
%disp (' ')
%fprintf ('oder _______________________________%g \n',min(ergebnis))

ergebnis2
fprintf ('maximale Korrelation Bizeps-EMG mit Aktometer für alle time-lags zwischen 0 und %g \n',weite)
fprintf ('beträgt_____________________________ %g  \n',max(ergebnis2))
%disp(' ')
%fprintf ('oder ________________________________%g \n',min(ergebnis2))

disp (' ')


%pause
%aamove