function [filemat_1] = combineconditionsERP(filemat_1, filemat_2, suffix) 

for index = 1:size(filemat_1,1)

    MergeAvgFiles([filemat_1(index,:); filemat_2(index,:)], [filemat_1(index,:) '.' suffix], 1, 1, [], 0, [], [], 0, 0)

end