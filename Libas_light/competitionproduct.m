function [ competitionvec ] = competitionproduct( mat_Tag1, mat_Tag2 )
% computes if the change/diferences in amplitude between conditions or blocks in one tag is
% co-occuring with a change/difference in the opposite direction at the other tag
% inputs are matrices with the individual tags, reference condition as the
% first column; if they have more than two columns then the subsequent
% columns are also considered, in order.

competitionvec = diff(mat_Tag1, [], 2) .* diff(mat_Tag2, [], 2)



