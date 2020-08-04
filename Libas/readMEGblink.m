% readMEGblink
function [blink] = readMEGblink(filepath)

a = ReadAvgFile(filepath)

blink = a(150,:).*10.^6;

plot(blink - mean(blink(1:100)));
