% Berechne Korrelationskoeffizienten
% für alle Varaiablen (akt1,uni2,uni3,akt2)
% in geladener datei, die zuvor in useac umbenannt wurde


r1= corrcoef (uni3(tid),akt2(tid));
r2= corrcoef (uni2(tid),akt2(tid));
r3= corrcoef (uni3(tid),akdif(tid));
r4= corrcoef (uni2(tid),uni3(tid));
r5= corrcoef (uni2(tid),akdif(tid));
r6= corrcoef (akt1(tid),akt2(tid));
r7= corrcoef (akt1(tid),uni2(tid));

if set == 1
disp ('KORRELATION im Teil standardisierte Bewegungen (TASK)')
else
disp ('KORRELATION im Teil freie Aktivität (ADL)') 
end

%fprintf ('beträgt für    VERSUCHSPERSON %g   zwischen...\n',num),fprintf ('Aktometer am Handgelenk und Unterarm-EMG____%g \n',r1(2,1))
%disp(' ')
%fprintf ('Aktometer am Handgelenk und Bizeps-EMG______%g \n',r2(2,1))
%disp(' ')
%fprintf ('Aktometernettowerten und Unterarm-EMG________%g \n',r3(2,1))
%disp(' ')
%fprintf ('Unterarm- und Bizeps-EMG____________________%g \n',r4(2,1))
%disp(' ')
%fprintf ('Bizeps-Emg und Aktometernettowerte__________%g\n',r5(2,1))
%disp(' ')
%fprintf ('den beiden Aktometern________________________%g \n',r6(2,1))
%disp (' ')
%fprintf ('Hüftaktometer und Bizeps-EMG________________%g \n',r7(2,1))
%disp(' ')


aamove


