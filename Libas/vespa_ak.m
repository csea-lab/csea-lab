function[corrvec, vespa] = vespa_ak(appmat)

sequence2 = repmat([1 1 1 0 0 0],1,4);          %24-element loops: each has 3*8.33*24 ms = 600 ms
sequence1 = repmat([1 1 1 1 0 0 0 0], 1,3);

count = 1; 
outvec = []; 
for loopindex = 1:6 % go through the 35-element loop 6 times
for flipindex = 1:24
outvec(count) = 0; 
if sequence1(flipindex) == 1, outvec(count) = outvec(count) +1; end
if sequence2(flipindex) == 1, outvec(count) = outvec(count) +1; end
if sequence1(flipindex) == 0, end
if sequence2(flipindex) == 0, end
length(outvec)
count = count + 1

end
end
plot(outvec)

%turn this into ms
count = 1
 for x = 1:25:3600; 
outvecms(x:x+24) = outvec(count); count = count +1; 
 end
 
 % now sample this function at 500 Hz (i.e take every second one) 
 corrvec = outvecms(1:2:3600); 

 