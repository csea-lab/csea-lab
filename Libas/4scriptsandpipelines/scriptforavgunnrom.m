for subject = 1:19,
a = readavgfile(filemat_hamp11(subject,:));a = bslcorr(a, [100:125]);
b = readavgfile(filemat_hamp12(subject,:));b = bslcorr(b, [100:125]);
c = readavgfile(filemat_hamp21(subject,:));c = bslcorr(c, [100:125]);
d = readavgfile(filemat_hamp22(subject,:));d = bslcorr(d, [100:125]); 

%elecvec4avg = [ 104 105 112:118 121:127 143:140 146:151 157:160 166:169 175:177 188 189 200]; 
elecvec4avg = [  105 112:116 121:125 143:138 146:149 157:158 166:167 175:176 ]; 

allmat4findmax = [a b c d]; 
lemax = max(max(allmat4findmax(elecvec4avg,:))); 
a = a./lemax; 
b = b./lemax; 
c = c./lemax; 
d = d./lemax; 
figure


subplot(2,1,1), plot(mean(a(elecvec4avg,:))), hold on, plot(mean(b(elecvec4avg,:)),'r');
subplot(2,1,2), plot(mean(c(elecvec4avg,:))), hold on, plot(mean(d(elecvec4avg,:)),'r'); pause
if subject == 1; mean11 = mean(a(elecvec4avg,:)); mean12 = mean(b(elecvec4avg,:)); mean21 = mean(c(elecvec4avg,:)); mean22 = mean(d(elecvec4avg,:)); 
else mean11 = [ mean11; mean(a(elecvec4avg,:))]; mean12 = [mean12; mean(b(elecvec4avg,:))]; mean21 = [mean21; mean(c(elecvec4avg,:))]; mean22 = [mean22; mean(d(elecvec4avg,:))]; 
end
    
end