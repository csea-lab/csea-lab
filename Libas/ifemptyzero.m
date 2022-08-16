function [outscalar] = ifemptyzero(inscalar)
% takes a scalar or one-cell input, outputs the scalar if not empty
% outputs zero if empty

if isempty(inscalar)
    outscalar = 0; 
else
    outscalar = inscalar; 
end
