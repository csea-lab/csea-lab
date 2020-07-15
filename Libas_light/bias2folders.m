function [outmat] = bias2folders(folder1, folder2, filemat1, filemat2); 

outmat = []; 

for subject = 1:size(filemat1,1); 
    
    data1 = ReadAvgFile(deblank([folder1 '/' filemat1(subject,:)])); 
    data2 = ReadAvgFile(deblank([folder2 '/' filemat2(subject,:)])); 
    
    data1 = data1./mean(mean(data1)); 
    data2 = data2./mean(mean(data2)); 
    
    databias1 = (data1 - data2); 
    
    plot(databias1(136,:)), title(filemat1(subject,10:20)), pause
    
    outmat(:, :, subject) = databias1; 
    
end

