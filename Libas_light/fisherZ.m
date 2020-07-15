%fisherZ
function [outmat] = fisherZ(inmat); 

outmat = 0.5.*log((1+inmat)./(1-inmat));