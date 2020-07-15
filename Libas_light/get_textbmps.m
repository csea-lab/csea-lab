function [m] = get_textbmps(word);


textin = deblank(word)

f = figure; 
p = patch([0; 0; 1; 1;0; 1; 0; 1], [0; 1; 0; 1;0; 0; 1; 1], [.0 .0 .0])
set(p, 'LineStyle', '.')
h = text(0.5,0.5,textin)
set(h,'HorizontalAlignment', 'center'),set(h,'FontSize', 60)
set(h,'FontName', 'times'), set(h,'Color', [0.8 0.8 0.8])
set(f, 'Color', [0.0 0.0 0.0])

pause(2)
m = getframe; 

imwrite(m.cdata(:,:,:), [textin '.bmp'], 'bmp')