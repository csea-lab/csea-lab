% tempget
function [endvec] = tempget(filemat, picvec_all); 

endvec = ones(1,60) .* -9;
picturevec = str2num(char(filemat(:,11:14))) 

for pictureIndex = 1 : 60
matindex = find(picturevec == picvec_all(pictureIndex))
if ~isempty(matindex), a = ReadAvgFile(char(filemat(matindex,:))); endvec(pictureIndex) = mean(a([72 156 67 129])); end
end