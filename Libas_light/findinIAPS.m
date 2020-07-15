% findinIAPS
function [index_out, outvalues] = findinIAPS(picnumvec)

load  num_aro_mat.mat

for x = 1 : size(picnumvec,1)
    [ind,anz] = find(num_aro_mat(:,1) == picnumvec(x));
    if ~isempty(ind), index_out(x) = ind(1,1); 
    else index_out(x) = 4; 
    end
end

outvalues = num_aro_mat(index_out,2)