function [data3d] = read_alon(filepath, epochlength)
% reads alon's besa format
% 

datalong = read_avr(filepath)';

data3d_temp = reshape(datalong, epochlength, size(datalong,1)/epochlength, 30); 

data3d = permute(data3d_temp, [3 1 2]); 

eval(['save ' filepath '.mat data3d'])




