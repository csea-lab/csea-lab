for fileindex = 100 : size(filemat_1, 1)
strucmat = load(deblank(filemat_1(fileindex, :)));
mat = strucmat.CON_BPMmat; datamat = bslcorr(mat,3:4);
disp(filemat_1(fileindex, :))
subplot(1,3,1), plot(datamat(:, 3:10)'), title(filemat_1(fileindex, :))
stdvec = std(datamat(:, 3:10)'); threshmedianstd = median(stdvec).*4
subplot(1,3,2), plot(stdvec'), title(num2str(threshmedianstd))

corrindex = find(stdvec > threshmedianstd); 
matnew = mat; 
matnew(corrindex, 2:10) = repmat(mean(mat(:,2:10)), length(corrindex), 1);

datamatnew = bslcorr(matnew,3:4);

subplot(1,3,3), plot(datamatnew(:, 3:10)'), title(filemat_1(fileindex, :))

CON_BPMmat = matnew; 

eval(['save ' deblank(filemat_1(fileindex, :)) '.corr.mat CON_BPMmat -mat']);


indices_11 = find(CON_BPMmat(:, 1) == 11)
indices_12 = find(CON_BPMmat(:, 1) == 12)
indices_21 = find(CON_BPMmat(:, 1) == 21)
indices_22 = find(CON_BPMmat(:, 1) == 22); 
indices_31 = find(CON_BPMmat(:, 1) == 31); 
indices_32 = find(CON_BPMmat(:, 1) == 32);
indices_41 = find(CON_BPMmat(:, 1) == 41);
indices_42 = find(CON_BPMmat(:, 1) == 42);

BPMmat = CON_BPMmat(:, 2:10); 


BPMavgmat8cond = [mean(BPMmat(indices_11,:)); mean(BPMmat(indices_12,:)); mean(BPMmat(indices_21,:)); mean(BPMmat(indices_22,:)); ...
    mean(BPMmat(indices_31,:)); mean(BPMmat(indices_32,:)); mean(BPMmat(indices_41,:)); mean(BPMmat(indices_42,:))] 

BPMavgmat8cond_bsl = bslcorr(BPMavgmat8cond, 1:2); 

eval(['save ' deblank(filemat_1(fileindex, :)) '.avg8con.mat BPMavgmat8cond_bsl -mat']); 


pause, end