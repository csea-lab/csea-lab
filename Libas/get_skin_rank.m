% findinIAPS
function [rankvec, compvec] = get_skin_rank(arovalues, skinvec)

compvec = arovalues + skinvec .*1000; 

[u,n] = sort(compvec); 

for index = 1:length(compvec)
    rankvec(n(index)) = index; 
end