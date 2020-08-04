% get_normarousal
function [normarovec] = get_normarousal(picvec);

load num_aro_mat; 

for index = 1:length(picvec)
aha = find(num_aro_mat(:,1) == picvec(index)); normarovec(index)=num_aro_mat(aha(1),2);
end