% analysiert kippfigurendaten; diese müssen zuvor in datei 
% "Kipp" überführt worden sein.

fname = 'e12';
for i= 2 : 5
eval (['load ',fname,int2str(i),'.dat'])

kipp = eval([fname,int2str(i)]);

[fname,int2str(i)]

% 1. ablängen der Datei auf 90 sec = 720 Punkte bei 8Hz Storage rate


if length(kipp) < 720

  kipp(length(kipp)+1 : 720)=zeros(720-length(kipp),1);

end


kipp = kipp(1:720);


% 2. Gesamtdauer der Wahrnehmung alternativer Perzepte

dauer1=0;
dauer2=0;

for n = 1:720;

   if kipp(n)==0
   dauer1 = dauer1+1;
   else
   dauer2 = dauer2+1;
   end

end
tdauer1=dauer1/8;
tdauer2=dauer2/8;

fprintf ('Taste NICHT gedrückt für %g Sekunden\n', tdauer1)
disp(' ')
fprintf ('Taste gedrückt für %g Sekunden\n', tdauer2) 


% 3. Ermittlung der Frequenz

kipprate = 0;

for n= 1:719;

   if kipp(n)~=kipp(n+1)
   kipprate= kipprate+1;
   end

end

fprintf ('Vp zeigte %g mal ein Kippen der Figur an\n', kipprate)

pause
kipp =[]
end