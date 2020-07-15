%fisher_z
% reads avector or matrix, transforms it to fisher-z
function [outmat] = fisher_z(inmat); 
outmat = .5 * log((1+(inmat)) ./ (1- (inmat))); 
