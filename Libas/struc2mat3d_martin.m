function [ newmat ] = struc2mat3d_martin( filemat )
%takes martin struc format and turns into 3d format,
% channels, by time, by trials, 

for file = 1:size(filemat,1)

        a =  load(filemat(file,:));
        
        newmat = zeros(65, 1425, 128);

        b = a; 
        
        names = fieldnames(b), pause

        for chan = 1:65;

        newmat(chan,:,:) = getfield(b, char(names(chan)))';

        end
        
        eval(['save ' filemat(file,:) '.3d.mat newmat -mat'])

end

