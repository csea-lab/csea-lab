function [schwelle] = digits2backspan(invec)% reads 8 element vector and outputs forward digit span% weights first two items by 1, other items by 2% alternativ vorwaerts: [schwelle] = digits2forespan(invec)if length(invec) ~= 14, error('falsche anzahl von nullen und einsen, nadine :-)'), break, endinvec(1:2) = invec(1:2).*1
invec(3:14) = invec(3:14).*2;
schwelle = (sum(invec)/26) .* 8; 