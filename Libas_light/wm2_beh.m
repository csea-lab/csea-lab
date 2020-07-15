function[pc1, pc2, pc3, pc4] = wm2_beh(CONfile)

% list all conditions
convec = ReadData(CONfile, 1, [], 'ascii', 'ascii'); 

%% STUDY ONE 

[c1, ~] = size(find(convec == 11)); % correct
[w1, ~] = size(find(convec == 10)); % wrong

[c2, ~] = size(find(convec == 21)); % correct
[w2, ~] = size(find(convec == 20)); % wrong

[c3, ~] = size(find(convec == 31)); % correct
[w3, ~] = size(find(convec == 30)); % wrong

[c4, ~] = size(find(convec == 41)); % correct
[w4, ~] = size(find(convec == 40)); % wrong

% percent correct
pc1 = c1 / (c1 + w1);
pc2 = c2 / (c2 + w2);
pc3 = c3 / (c3 + w3);
pc4 = c4 / (c4 + w4);

end