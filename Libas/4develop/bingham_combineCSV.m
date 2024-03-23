filemat = getfilesindir(pwd, '*.snr.csv')
statmat = []; 

for fileindex = 1:size(filemat,1)

    a = readtable(deblank(filemat(fileindex,:))); 

    statmat(fileindex,:) = table2array(a)
end

writematrix(statmat, 'statmat_test.csv')