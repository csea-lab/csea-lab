function [movmat] = getABmovie(t1pos, t2pos, textfilepath);

fid = fopen(textfilepath); 


for j = 1 : 19
textin = fgetl(fid)

f = figure; 
p = patch([0; 0; 2; 2;0; 2; 0; 2], [0; 2; 0; 2;0; 0; 2; 2], [.3 .3 .3])
set(p, 'LineStyle', '.')
h = text(1,1,textin)
set(h,'HorizontalAlignment', 'center'),set(h,'FontSize', 42)
set(h,'FontName', 'courier'), set(h,'Color', [0.9 0.9 0.9])
if j == t1pos | j == t2pos, set(h,'Color', [0 1 0]), end

pause(2)
movmat(j) = getframe
pause(2)
end