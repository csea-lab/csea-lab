%       ein Programm zur Analyse der Aktometerauf-
%       zeichnungen  
%       Datenfiles müssen zuvor in zweispaltige datei "coor" 
%       überführt werden.


clear links
clear rechts
clear q
clear row
clear j
clear fname

%fname = 'k06';
%for i= 3:3:6
%eval (['load ',fname,int2str(i),'.dat'])

%coor = eval([fname,int2str(i)]);

%[fname,int2str(i)]


links = coor (:,1)-127;
rechts = coor (:,2)-127;

q = length (links);

fprintf ('Anzahl Meßpunkte beträgt %g \n',q)
fprintf (' ')
fprintf ('entspricht %g Sekunden \n',q/44.44)

FILE = input ('gib Filename  ','s');


clf 
figure (1)
subplot (2,1,1)
plot (links)
title ('Aktometer 1')
xlabel('T')
ylabel ('Beschleunigung')

subplot (2,1,2)
plot (rechts)
title ('Aktometer 2')
xlabel('T')
ylabel ('Beschleunigung')

disp ('Teilbereich auswählen')

[bvon,ya] = ginput(1);
[bbis,yb] = ginput(1);

teil = (bvon:bbis);

disp ('Teilbereichsgrenzen:'), disp (bvon), disp (bbis)
disp (' ')
disp ('entspricht in Sekunden:'), disp (bvon/44.44), disp ('bis'), disp (bbis/44.44)

figure(2)
subplot (2,1,1)
plot (links(teil))
title ('Aktometer 1 (TEIL)')
xlabel('T')
ylabel ('Beschleunigung')

subplot (2,1,2)
plot (rechts(teil))
title ('Aktometer 2 (TEIL)')
xlabel('T')
ylabel ('Beschleunigung')

end
	
	%  filtern

% filtert Ausschnitt


a = [1,-0.3];
b = 1;

L = filtfilt (b,a,links);
R = filtfilt (b,a,rechts);
figure(3)
subplot (2,1,1)
plot (L(teil))
title ('Aktometer 1 (TEIL) gefiltert')
xlabel('T')

subplot (2,1,2)
plot (R(teil))
title ('Aktometer 2 (TEIL) gefiltert')
xlabel('T')

H=corrcoef (links(teil),rechts(teil));
fprintf ('Korrelation der Teilabschnitte (ungefiltert) beträgt %g\n',H(2,1))

H2=corrcoef (L(teil),R(teil));
fprintf ('Korrelation der Teilabschnitte (gefiltert) beträgt %g\n',H2(2,1))
KOFI=num2str(H2(2,1));

pause

lor=menu('Kanal auswählen','Akt1','Akt2');
if lor == 1
F = L;
else
F = R;
end


% bestimme die Frequenz für erstes 256er Fenster mit fft

FF = fft(F(teil),256);

Pyy = FF.*conj(FF)/256;

FF=[];


%	frequency axis:

f = 44.44/256*(0:128);

plot(f(1:30),Pyy(1:30)), title('Power spectral density'), ...
xlabel('Frequency (Hz)')

[fre,c]=ginput(1);

disp(' ')
fprintf ('Frequenz für Teilausschnitt beträgt %g Hertz\n',fre)
teilfrq = num2str(fre)


pause
	% zeige Phasenporträt links vs rechts

figure(4)

plot (links(teil),rechts(teil))
axis ([-250 250 -250 250])
xlabel ('links (TEIL)')
ylabel ('rechts(TEIL)')
title('Phasenporträt links vs rechts (Ausschnitt)')
text(-200,200,FILE)
text(-200,-200,'Cross-correlation für Abschnitt (gefiltert):')
text(100,-200,KOFI)
text(-150,200,'Frequenz für diesen Abschnitt in Hz:')
text(70,200,teilfrq)



%pause

	%       dreiD-lag analyse  mit lag 6
	%       Plotten von top. äq. Attraktor aus 4 Perspektiven



figure(5)

X = [1:(length(F(teil))-12)];
Y = [7:(length(F(teil))-6)];
Z = [13:length(F(teil))];


subplot(2,2,1)
plot3(F(teil(X)),F(teil(Y)),F(teil(Z)))
axis('equal')
view(-40,30)
xlabel('X'),ylabel('Y'),zlabel('Z')
title ('rekonstruierter Attraktor für gewählten Ausschnitt')

subplot(2,2,2)
plot3(F(teil(X)),F(teil(Y)),F(teil(Z)))
axis('equal')
view(-10,30)
xlabel('X'),ylabel('Y'),zlabel('Z')

subplot(2,2,3)
plot3(F(teil(X)),F(teil(Y)),F(teil(Z)))
axis('equal')
view(20,30)
xlabel('X'),ylabel('Y'),zlabel('Z')
title (FILE)

subplot(2,2,4)
plot3(F(teil(X)),F(teil(Y)),F(teil(Z)))
axis('equal')
view(50,30)
xlabel('X'),ylabel('Y'),zlabel('Z')



