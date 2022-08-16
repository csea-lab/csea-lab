% sucht Nulldurchgänge in file move (beschlprofil), errechnet Frequenz
% durch invertierung der Wellenlänge; erstellt häufigkeitserteilung 
% der gefundenen frequenzen.


% 1. Ermittle ersten Intervall zwischen Vorzeichenwechseln


schw =0;
start=1;
k=1;

for n = start: length (move) 
   if move(n)<0
      schw=schw+1;
      else
      break   % anz. Punkte wo acc < 0
   end
end


schw(k)
k=k+1

start=n

aapos