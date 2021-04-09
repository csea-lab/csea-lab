function [] = niftifix(filemat) 
% header length is 348 Bytes divided by 2

fclose('all')
 

for fileindex = 1:size(filemat,1)

% for comparison, use niftiread/info
info_old = niftiinfo(deblank(filemat(fileindex,:)));

fid  = fopen(deblank(filemat(fileindex,:)));
[data, count] = fread(fid, 'int16'); % read binary
data_fread = int16(data(177:end)); % header is 176 when read in as int16  

% from here, figure out how many images there are
%length of data in an ideal world
fullength = info_old.ImageSize(1)*info_old.ImageSize(2)*info_old.ImageSize(3)*info_old.ImageSize(4);
imagelength  = info_old.ImageSize(1)*info_old.ImageSize(2)*info_old.ImageSize(3); 

imageindex = 1; 
while imagelength*imageindex < length(data_fread)
    imageindex = imageindex + 1;
end

actualNTrs  = imageindex-1; % actualNTrs is the actual number of images

data_fread = data_fread(1:imagelength*(actualNTrs)); 

data_fread_reshaped = (reshape(data_fread, [info_old.ImageSize(1:3) actualNTrs]));

 % edit the info
 info_new = info_old;
 info_new.Filename = [info_old.Filename 'fixed'];
 info_new.ImageSize = [info_old.ImageSize(1:3) actualNTrs];
 info_new.raw.dim(5) = [actualNTrs];
 info_new.Filesize = [];
 
 niftiwrite(data_fread_reshaped, ['fixed.' filemat(fileindex,:)] , info_new)

end %file loop

end %function

