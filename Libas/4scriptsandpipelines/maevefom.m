clear mat*
for x = 1:21; mat1(:, :, x) = ReadAvgFile(deblank(filemat_1(x,:))); end
for x = 1:21; mat2(:, :, x) = ReadAvgFile(deblank(filemat_2(x,:))); end

matdiff = mat2-mat1;

%elek = [ 69:72 74:77]
%elek = [ 82:86]
elek = 75


%for elek = 1:129
figure(102)
subplot(3,1,1), bar(squeeze(mean(mat1(elek, 25,:),1))), title(num2str(elek)); 
subplot(3,1,2), bar(squeeze(mean(mat2(elek, 25,:),1)))
subplot(3,1,3), bar(squeeze(mean(matdiff(elek, 25,:),1))), pause(1),
%end

%% loop through SNRs

for x =1:20
    
noisebins = [25-x:24 26:25+x]; 

for x = 1:21; mat1SNR(:, :, x)  = mat1(:, :, x)./repmat(squeeze(mean(mat1(:, noisebins, x),2)), 1, size(mat1,2)); end

for x = 1:21; mat2SNR(:, :, x)  = mat2(:, :, x)./repmat(squeeze(mean(mat2(:, noisebins, x),2)), 1, size(mat2,2)); end

matdiffSNR = mat2SNR-mat1SNR;
figure(99), title(num2str(noisebins))
subplot(3,1,1), bar(squeeze(mat1SNR(75, 25,:)))
subplot(3,1,2), bar(squeeze(mat2SNR(75, 25,:)))
subplot(3,1,3), bar(squeeze(matdiffSNR(75, 25,:))), title(num2str(noisebins)), pause

end

%% Loop through hilberts
for x = 1:21; mat1(:, :, x) = ReadAvgFile(deblank(filemat_1(x,:))); end
for x = 1:21; mat2(:, :, x) = ReadAvgFile(deblank(filemat_2(x,:))); end

matdiff = mat2-mat1;

elek = 75
figure(101)

subplot(3,1,1), plot(squeeze(mat1(elek, :,:))), 
subplot(3,1,2), plot(squeeze(mat2(elek, :,:)))
subplot(3,1,3), plot(squeeze(matdiff(elek, :,:))), grid,  pause

%% loop through sec half
clear mat*
for x = 1:21; mat1(:, :, x) = ReadAvgFile(deblank(filemat_1(x,:))); end
for x = 1:21; mat2(:, :, x) = ReadAvgFile(deblank(filemat_2(x,:))); end

matdiff = mat2-mat1;


elek = [ 75]
figure
subplot(3,1,1), bar(squeeze(mean(mat1(elek, 13,:))))
subplot(3,1,2), bar(squeeze(mean(mat2(elek, 13,:))))
subplot(3,1,3), bar(squeeze(mean(matdiff(elek, 13,:))))




