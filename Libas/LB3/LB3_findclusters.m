%% cluster-ready
clear
%load('/Users/andreaskeil/Documents/GitHub/csea-lab/Libas/4data/elekFieldTrip257HCL.mat')

%data  = zeros(257,1); data([122 123 124 125 115 136 135 146 114 106 96]) = 4; 
data = zeros(26,1); data(1:4) = 4; 

coor3d = sensors.chanpos;
if norm(coor3d(1,:)) < 1.1
    coor3d = coor3d.*4; 
end

shrink3d_1 = round(coor3d./1.5); % shrunk coordinates in original space (zero-centered) 
shrink3d_2 = shrink3d_1+abs(min(min(shrink3d_1)))+1; % now in absolute, positive coordinates that can be used as indices

volume = zeros(max(shrink3d_2(:, 1)), max(shrink3d_2(:, 2)), max(shrink3d_2(:, 3)));

for elc = 1:size(data,1) % loop over sensors

volume(shrink3d_2(elc,1), shrink3d_2(elc,2), shrink3d_2(elc,3)) = data(elc) ;

end

BW = imbinarize(volume, 3);


CON = bwconncomp(BW);

clustIdx = CON.PixelIdxList;
            labelmat = labelmatrix(CON);
            clustersize = zeros(1, CON.NumObjects); 
            clusterSums = zeros(1, CON.NumObjects);
            for clusterindex = 1:CON.NumObjects   
                clustersize(clusterindex) = sum(sum(sum(labelmat == clusterindex)));
                clusterSums(clusterindex) = sum(mat2vec(volume(labelmat == clusterindex)));
            end
            sizevec = [sizevec max(clustersize)];
            sumDistvec = [sumDistvec min(clusterSums)];


%%
