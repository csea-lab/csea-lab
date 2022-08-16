clear SNR
filemat = getfilesindir(pwd);
filemat_set = filemat(2:2:end,:);
for subject = 1:size(filemat_set,1) 
    eeg = pop_loadset(filemat_set(subject,:));
    [~,winmat3d,phasestabmat,SNR(:, subject)] = flex_slidewin(eeg.data, 0, 1:1000, 1000:size(eeg.data,2), 2.77, 554, 500, 'test');
end

 mean(SNR([6 7 28 29], :))'