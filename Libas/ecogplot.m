function [] = ecogplot(gridlocmat, pairmat, values, caxisvec)
% gridlocmat = 2-d matrix of electrode names corresponding to electrode
% names (numbers) in pairmat, e.g., 21 22 23 24 25; 26 27 28 29 30; ...
% arranged as on brain. pairmat is n by 2 mat of electrode pairs for
% bipolar data, used to interpolate locations, values are values...

% first step: find coordinates for drawing the bipolar data (in between
% sensors)

for index1 = 1:size(pairmat,1)
    
    [y1,x1] = find(pairmat(index1, 1) == gridlocmat); % x and y switched for correct mapping on brain (where x = l/r and y = topo/bottom)
    [y2,x2]= find(pairmat(index1, 2) == gridlocmat);
    
    newx(index1) = (1.1*x1+x2)./2;  % weigh one x and y differently to avoid identical coordinates for crossovers
    newy(index1) = (y1 + 1.1*y2)./-2; % in addition y inverted because row =1 is top but y = 1 is bottom in brain
    
  %  plot(newx(index1), newy(index1), 'r*'), title(num2str(pairmat(index1,:))), hold on, pause(.1), plot(newx(index1), newy(index1), 'b*')
    
end

newx = newx';
newy = newy';

dt = DelaunayTri(newx,newy);

xlin=linspace(min(newx),max(newx),30);
ylin=linspace(min(newy),max(newy),30);

[X,Y]=meshgrid(xlin,ylin);

Z=griddata(newx,newy,values,X,Y, 'cubic');

surf(X,Y,Z); caxis([caxisvec]), view(0,90), colorbar, shading interp
 