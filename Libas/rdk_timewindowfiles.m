function [outmat] = rdk_timewindowfiles(filemat, timewindowvec, lengthofwin);
%program to average over electrode cluster for all subjects and get average ssvep amplitude for 5 time windows of interest
% wants a filemat and a vector of starting times for timewindows, each of
% which has the same length in sample points

outmat = []; 
for index = 1:size(filemat,1)
a = ReadAvgFile(filemat(index,:));
%b = bslcorr(a,[50:80]);
b = a; 
length(timewindowvec)
for timewin = 1: length(timewindowvec)
outvec(timewin) = mean(mean(b([116:118 124:128 137:140 149:151 159:160], timewindowvec(timewin):timewindowvec(timewin)+lengthofwin)));
end
outmat = [outmat; outvec]; 
end
