% berechnet anzahl wendepunkte
% pro zyklus in 60 bpm daten


clear links
clear rechts
clear q
clear row
clear j
clear fname
clear Z
clear Mat
clear w

namevec ['name1'; 'name2'; 'name3'] % usw.  hier sind die (gleich langen) filenamen einzutragen,
                                    % die in einem verzeichnis stehen, das matlab
                                    % im Suchpfad hat

for fileindex = 1 : length(namevec);

fname = namvec(fileindex,:)

fsamp = 100;

eval (['load ',fname]);

Mat = eval (fname);


plot (Mat)

disp ('choose part of vector to work with')

[bvon,ya] = ginput(1);
[bbis,yb] = ginput(1);

teil = (bvon:bbis);

plot (Mat(teil))


disp ('Teilbereichsgrenzen:'), disp (bvon), disp (bbis)
disp (' ')
disp ('entspricht in Sekunden:'), disp (bvon/fsamp), disp ('bis'), disp (bbis/fsamp)


% berechne optimale Anzahl der wendepunkte fuer segment bei 60 zyklen pro minute
% 1. laenge des segments in sec

lengseg = bbis/fsamp - bvon-fsamp;
infpointsopt = lengseg*2

% berechne Anz tats. wendepunkte


for n = 1 : length (Mat(teil))-1

Z(n) = Mat(teil(n+1)) - Mat(teil(n));  % vektor mit Steigung/differential

end

wp = 0 ; wp counts inflection points

for n = 1 : length (Z)-1

 if Z(n)*Z(n+1)<=0 & Z(n)~=0 | Z(n+1)~=0
   wp = wp+1;	
 end

end

fprintf ('optimale Anzahl Zyklen: %g\n',infpointsopt)
disp (' ')
fprintf ('Anzahl der Wendepunkte: %g\n',wp)
disp(' ')
fprintf ('mittlere Anzahl Wendepunkte pro Zyklus %g\n',wp/infpointsopt/2)

%save C:\..........\
end  % ende schleife eines files