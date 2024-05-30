function bingham_combinetags(Gabornamedfile,Facenamedfile, name4save)
% explanation
% this function combines conditions across counterbalanced frequencies
% input should be the GM spectrum .at file and name4save can be emotion
% type

spec1 = ReadAvgFile(Gabornamedfile);
spec2 = ReadAvgFile(Facenamedfile);

Facetags = (spec1(:, 61) +  spec1(:, 76)) ./2;
Gabortags = (spec2(:, 76) +  spec2(:, 61)) ./2;

SaveAvgFile(['GMFace_' name4save '.at'], Facetags(1:31,:), [], [], [])
SaveAvgFile(['GMGabor_' name4save '.at'], Gabortags(1:31,:), [], [], [])

