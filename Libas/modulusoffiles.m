function [] = modulusoffiles(filemat1,filemat2, filemat3, outnamextension, fsamp, informat)
% inputs: three filemats from three orientations of the MNE space
% outname extension: a short string that indicates what the files is now,
% e.g. absMNE
% fsamp: if spec files, this is NOT the sample rate in the time domain but
% the fake sample rate we use to make emegs2d show Hz in ms
% informat: 1 for mat files, 2 for atg files

for x = 1:size(filemat1,1); 
    
    if informat == 1; % informat = 1: mat files
    a = load(deblank(filemat1(x,:))); 
    b = load(deblank(filemat2(x,:))); 
    c =  load(deblank(filemat3(x,:))); 
    data1 = eval(['a.' char(fieldnames(a)) ';']);
    data2 = eval(['b.' char(fieldnames(b)) ';']);
    data3 = eval(['c.' char(fieldnames(c)) ';']);
    else
    data1 = ReadAvgFile(deblank(filemat1(x,:))); 
    data2 = ReadAvgFile(deblank(filemat2(x,:))); 
    data3 =  ReadAvgFile(deblank(filemat3(x,:))); 
    end

    
    dataout = sqrt(data1.^2 + data2.^2+ data3.^2); 
        
     SaveAvgFile([deblank(filemat1(x,1:end-9))  outnamextension '.atg'], dataout, [], [], fsamp); 
        
end 
 