function [] = rdk_timewindow(filemat);
%program to average over electrode cluster for all subjects and get average ssvep amplitude for 5 time windows of interest


%Time 1: 2800 - 3970ms 
%%
for index = 1:19
a = ReadAvgFile(filemat_1(index,:));
b = bslcorr(a,[50:80]);
ero_vec1(index) = mean(mean(b([116:118 124:128 137:140 149:151 159:160], 801:1094)));
end, ero_vec1 = ero_vec1'
% ^ goes through each condition file and averages over cluster and time point; assigns variable name for ssvep amplitude average 
ero_ampavg = (mean(ero_vec1)/2) %mean of the amplitudes for erotic condition

for index = 1:19
a = ReadAvgFile(filemat_2(index,:));
b = bslcorr(a,[50:80]);
cat_vec2(index) = mean(mean(b([116:118 124:128 137:140 149:151 159:160], 1101:1226)));
end, cat_vec2 = cat_vec2'
cat_ampavg = (mean(cat_vec2)/2) 

for index = 1:19
a = ReadAvgFile(filemat_3(index,:));
b = bslcorr(a,[50:80]);
wrk_vec3(index) = mean(mean(b([116:118 124:128 137:140 149:151 159:160], 1101:1226)));
end, wrk_vec3 = wrk_vec3'
wrk_ampavg = (mean(wrk_vec3)/2) 

for index = 1:19
a = ReadAvgFile(filemat_4(index,:));
b = bslcorr(a,[50:80]);
cow_vec4(index) = mean(mean(b([116:118 124:128 137:140 149:151 159:160], 1101:1226)));
end, cow_vec4 = cow_vec4'
cow_ampavg = (mean(cow_vec4)/2) 

for index = 1:19
a = ReadAvgFile(filemat_5(index,:));
b = bslcorr(a,[50:80]);
mut_vec5(index) = mean(mean(b([116:118 124:128 137:140 149:151 159:160], 1101:1226)));
end, mut_vec5 = mut_vec5'
mut_ampavg = (mean(mut_vec5)/2) 

for index = 1:19
a = ReadAvgFile(filemat_6(index,:));
b = bslcorr(a,[50:80]);
snk_vec6(index) = mean(mean(b([116:118 124:128 137:140 149:151 159:160], 1101:1226)));
end, snk_vec6 =snk_vec6'
snk_ampavg = (mean(snk_vec6)/2) 


timewindows = zeros(6, 5) %creates empty matrix of 0's, 6 rows (conditions) and 5 columns (time points)
timewindows(1,1) = ero_ampavg % makes the first row, first column filled with ero_ampavg value
timewindows(2,1) = cat_ampavg
timewindows(3,1) = wrk_ampavg
timewindows(4,1) = cow_ampavg
timewindows(5,1) = mut_ampavg
timewindows(6,1) = snk_ampavg
%%

%Time 2: 3970 - 5140 ms
%%
for index = 1:19
a = ReadAvgFile(filemat_1(index,:));
b = bslcorr(a,[50:80]);
ero_vec1(index) = mean(mean(b([116:118 124:128 137:140 149:151 159:160], 1094:1386)));
end, ero_vec1 = ero_vec1'
% ^ goes through each condition file and averages over cluster and time point; assigns variable name for ssvep amplitude average 
ero_ampavg2 = (mean(ero_vec1)/2) %mean of the amplitudes for erotic condition

for index = 1:19
a = ReadAvgFile(filemat_2(index,:));
b = bslcorr(a,[50:80]);
cat_vec2(index) = mean(mean(b([116:118 124:128 137:140 149:151 159:160], 1101:1226)));
end, cat_vec2 = cat_vec2'
cat_ampavg2 = (mean(cat_vec2)/2) 

for index = 1:19
a = ReadAvgFile(filemat_3(index,:));
b = bslcorr(a,[50:80]);
wrk_vec3(index) = mean(mean(b([116:118 124:128 137:140 149:151 159:160], 1101:1226)));
end, wrk_vec3 = wrk_vec3'
wrk_ampavg2 = (mean(wrk_vec3)/2) 

for index = 1:19
a = ReadAvgFile(filemat_4(index,:));
b = bslcorr(a,[50:80]);
cow_vec4(index) = mean(mean(b([116:118 124:128 137:140 149:151 159:160], 1101:1226)));
end, cow_vec4 = cow_vec4'
cow_ampavg2 = (mean(cow_vec4)/2) 

for index = 1:19
a = ReadAvgFile(filemat_5(index,:));
b = bslcorr(a,[50:80]);
mut_vec5(index) = mean(mean(b([116:118 124:128 137:140 149:151 159:160], 1101:1226)));
end, mut_vec5 = mut_vec5'
mut_ampavg2 = (mean(mut_vec5)/2) 

for index = 1:19
a = ReadAvgFile(filemat_6(index,:));
b = bslcorr(a,[50:80]);
snk_vec6(index) = mean(mean(b([116:118 124:128 137:140 149:151 159:160], 1101:1226)));
end, snk_vec6 =snk_vec6'
snk_ampavg2 = (mean(snk_vec6)/2) 



timewindows(1,2) = ero_ampavg2 % makes the first row, first column filled with ero_ampavg value
timewindows(2,2) = cat_ampavg2
timewindows(3,2) = wrk_ampavg2
timewindows(4,2) = cow_ampavg2
timewindows(5,2) = mut_ampavg2
timewindows(6,2) = snk_ampavg2
%%

%Time 3: 5140 - 6310 ms
%%

for index = 1:19
a = ReadAvgFile(filemat_1(index,:));
b = bslcorr(a,[50:80]);
ero_vec1(index) = mean(mean(b([116:118 124:128 137:140 149:151 159:160], 1386:1679)));
end, ero_vec1 = ero_vec1'
% ^ goes through each condition file and averages over cluster and time point; assigns variable name for ssvep amplitude average 
ero_ampavg = (mean(ero_vec1)/2) %mean of the amplitudes for erotic condition

for index = 1:19
a = ReadAvgFile(filemat_2(index,:));
b = bslcorr(a,[50:80]);
cat_vec2(index) = mean(mean(b([116:118 124:128 137:140 149:151 159:160], 1101:1226)));
end, cat_vec2 = cat_vec2'
cat_ampavg = (mean(cat_vec2)/2) 

for index = 1:19
a = ReadAvgFile(filemat_3(index,:));
b = bslcorr(a,[50:80]);
wrk_vec3(index) = mean(mean(b([116:118 124:128 137:140 149:151 159:160], 1101:1226)));
end, wrk_vec3 = wrk_vec3'
wrk_ampavg = (mean(wrk_vec3)/2) 

for index = 1:19
a = ReadAvgFile(filemat_4(index,:));
b = bslcorr(a,[50:80]);
cow_vec4(index) = mean(mean(b([116:118 124:128 137:140 149:151 159:160], 1101:1226)));
end, cow_vec4 = cow_vec4'
cow_ampavg = (mean(cow_vec4)/2) 

for index = 1:19
a = ReadAvgFile(filemat_5(index,:));
b = bslcorr(a,[50:80]);
mut_vec5(index) = mean(mean(b([116:118 124:128 137:140 149:151 159:160], 1101:1226)));
end, mut_vec5 = mut_vec5'
mut_ampavg = (mean(mut_vec5)/2) 

for index = 1:19
a = ReadAvgFile(filemat_6(index,:));
b = bslcorr(a,[50:80]);
snk_vec6(index) = mean(mean(b([116:118 124:128 137:140 149:151 159:160], 1101:1226)));
end, snk_vec6 =snk_vec6'
snk_ampavg = (mean(snk_vec6)/2) 



timewindows(1,3) = ero_ampavg % makes the first row, first column filled with ero_ampavg value
timewindows(2,3) = cat_ampavg
timewindows(3,3) = wrk_ampavg
timewindows(4,3) = cow_ampavg
timewindows(5,3) = mut_ampavg
timewindows(6,3) = snk_ampavg


%%

%Time 4: 6310 - 7480 ms
%%


for index = 1:19
a = ReadAvgFile(filemat_1(index,:));
b = bslcorr(a,[50:80]);
ero_vec1(index) = mean(mean(b([116:118 124:128 137:140 149:151 159:160], 1679:1971)));
end, ero_vec1 = ero_vec1'
% ^ goes through each condition file and averages over cluster and time point; assigns variable name for ssvep amplitude average 
ero_ampavg = (mean(ero_vec1)/2) %mean of the amplitudes for erotic condition

for index = 1:19
a = ReadAvgFile(filemat_2(index,:));
b = bslcorr(a,[50:80]);
cat_vec2(index) = mean(mean(b([116:118 124:128 137:140 149:151 159:160], 1101:1226)));
end, cat_vec2 = cat_vec2'
cat_ampavg = (mean(cat_vec2)/2) 

for index = 1:19
a = ReadAvgFile(filemat_3(index,:));
b = bslcorr(a,[50:80]);
wrk_vec3(index) = mean(mean(b([116:118 124:128 137:140 149:151 159:160], 1101:1226)));
end, wrk_vec3 = wrk_vec3'
wrk_ampavg = (mean(wrk_vec3)/2) 

for index = 1:19
a = ReadAvgFile(filemat_4(index,:));
b = bslcorr(a,[50:80]);
cow_vec4(index) = mean(mean(b([116:118 124:128 137:140 149:151 159:160], 1101:1226)));
end, cow_vec4 = cow_vec4'
cow_ampavg = (mean(cow_vec4)/2) 

for index = 1:19
a = ReadAvgFile(filemat_5(index,:));
b = bslcorr(a,[50:80]);
mut_vec5(index) = mean(mean(b([116:118 124:128 137:140 149:151 159:160], 1101:1226)));
end, mut_vec5 = mut_vec5'
mut_ampavg = (mean(mut_vec5)/2) 

for index = 1:19
a = ReadAvgFile(filemat_6(index,:));
b = bslcorr(a,[50:80]);
snk_vec6(index) = mean(mean(b([116:118 124:128 137:140 149:151 159:160], 1101:1226)));
end, snk_vec6 =snk_vec6'
snk_ampavg = (mean(snk_vec6)/2) 


%timewindows = zeros(6, 5) %creates empty matrix of 0's, 6 rows (conditions) and 5 columns (time points)
timewindows(1,4) = ero_ampavg % makes the first row, first column filled with ero_ampavg value
timewindows(2,4) = cat_ampavg
timewindows(3,4) = wrk_ampavg
timewindows(4,4) = cow_ampavg
timewindows(5,4) = mut_ampavg
timewindows(6,4) = snk_ampavg


%%

%Time 5: 7480 - 8650 ms
%%


for index = 1:19
a = ReadAvgFile(filemat_1(index,:));
b = bslcorr(a,[50:80]);
ero_vec1(index) = mean(mean(b([116:118 124:128 137:140 149:151 159:160], 1971:2264)));
end, ero_vec1 = ero_vec1'
% ^ goes through each condition file and averages over cluster and time point; assigns variable name for ssvep amplitude average 
ero_ampavg = (mean(ero_vec1)/2) %mean of the amplitudes for erotic condition

for index = 1:19
a = ReadAvgFile(filemat_2(index,:));
b = bslcorr(a,[50:80]);
cat_vec2(index) = mean(mean(b([116:118 124:128 137:140 149:151 159:160], 1101:1226)));
end, cat_vec2 = cat_vec2'
cat_ampavg = (mean(cat_vec2)/2) 

for index = 1:19
a = ReadAvgFile(filemat_3(index,:));
b = bslcorr(a,[50:80]);
wrk_vec3(index) = mean(mean(b([116:118 124:128 137:140 149:151 159:160], 1101:1226)));
end, wrk_vec3 = wrk_vec3'
wrk_ampavg = (mean(wrk_vec3)/2) 

for index = 1:19
a = ReadAvgFile(filemat_4(index,:));
b = bslcorr(a,[50:80]);
cow_vec4(index) = mean(mean(b([116:118 124:128 137:140 149:151 159:160], 1101:1226)));
end, cow_vec4 = cow_vec4'
cow_ampavg = (mean(cow_vec4)/2) 

for index = 1:19
a = ReadAvgFile(filemat_5(index,:));
b = bslcorr(a,[50:80]);
mut_vec5(index) = mean(mean(b([116:118 124:128 137:140 149:151 159:160], 1101:1226)));
end, mut_vec5 = mut_vec5'
mut_ampavg = (mean(mut_vec5)/2) 

for index = 1:19
a = ReadAvgFile(filemat_6(index,:));
b = bslcorr(a,[50:80]);
snk_vec6(index) = mean(mean(b([116:118 124:128 137:140 149:151 159:160], 1101:1226)));
end, snk_vec6 =snk_vec6'
snk_ampavg = (mean(snk_vec6)/2) 


%timewindows = zeros(6, 5) %creates empty matrix of 0's, 6 rows (conditions) and 5 columns (time points)
timewindows(1,5) = ero_ampavg % makes the first row, first column filled with ero_ampavg value
timewindows(2,5) = cat_ampavg
timewindows(3,5) = wrk_ampavg
timewindows(4,5) = cow_ampavg
timewindows(5,5) = mut_ampavg
timewindows(6,5) = snk_ampavg

%timewindows(1,:) = ero_times %makes the first row of timewindows equal the values assigned to ero_times