function [ outmat ] = atg2workspace( filemat )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

for sub = 1:size(filemat,1)

    outmat(:,sub) = ReadAvgFile(deblank(filemat(sub,:)));

end

