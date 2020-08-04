%fisher_unZ: retransforms a fisher-z'd value to the original scale
function [outmat] = fisher_unZ(inmat)


outmat = (exp(2.*inmat)-1)./(exp(2.*inmat)+1);