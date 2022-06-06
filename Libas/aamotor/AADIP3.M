% zeigt Cross-Korrelation der beiden Kanäle 
% für jeden Zeitpunkt mit einem Fenster von 64 Punkten

clf
clear V
clear R
clear unten
clear oben
clear links
clear rechts
clear G

links = coor (:,1)-127;
rechts = coor (:,2)-127;


li =length(links);

unten = 1 : (li-127);  % generiert Fenster mit 128 Punkten
oben = 128 : li;       % als Vektor V

for n = 1:length(unten);
    
    V= unten(n):oben(n);
   
    K = corrcoef (links(V),rechts(V));
     
    G(n)=K(2,1);
end


figure 
plot (oben,G)
xlabel ('n')
ylabel ('Korrelation')
title ('Cross-Correlation links vs rechts ')
text (150,-0.5,FILE)

pause

figure(10)
plot (oben,G)
xlabel ('n')
title ('cross-Korrelation (---) und Frequenz(...)')
hold on
plot (ZEIT,FRE,'g')