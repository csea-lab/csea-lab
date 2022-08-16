%   lädt die Datei, die analysiert werden soll und 
%   bennent sie um in "useac"
%   geht dann in analyseprogramme


clc
clf
aafipath


set = menu ('zu ladender datensatz','task','adl');

num = menu ('VP-Nummer','1','2','3','4','5','6');

if set == 1 & num == 1
load task1.dat; useac = task1;

elseif set == 1 & num ==2
load task2.dat; useac = task2;

elseif set ==1 & num == 3
load task3.dat; useac = task3;

elseif set ==1 & num == 4
load task4.dat; useac = task4;

elseif set ==1 & num == 5
load task5.dat; useac = task5;

elseif set ==1 & num == 6
load task6.dat; useac = task6;

elseif set == 2 & num ==1
load adl1.dat; useac = adl1;

elseif set == 2 & num == 2
load adl2.dat; useac = adl2;

elseif set ==2 & num ==3
load adl3.dat; useac = adl3;

elseif set ==2 & num ==4
load adl4.dat; useac = adl4;

elseif set ==2 & num ==5
load adl5.dat; useac = adl5;

elseif set ==2 & num ==6
load adl6.dat; useac = adl6;

else disp ('das war noch nichts')

end

% weist Kanäle zu

akt1 = sqrt((useac (:,1)-127).^2);
uni2 = useac (:,2);
uni3 = useac (:,3);
akt2 = sqrt((useac (:,4)-127).^2);
akdif = akt2-akt1;


aastart2

