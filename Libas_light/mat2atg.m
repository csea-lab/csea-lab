function [ mat ] = mat2atg(filemat, fsamp, trigpoint)

for index = 1:size(filemat,1)
  
    strucmat = load(deblank(filemat(index, :))); 
    mat = eval(['strucmat.' char(fieldnames(strucmat))]);
    
    SaveAvgFile([deblank(filemat(index, :)) '.at'],mat,[],[], ...
    fsamp,[],[],[],[],trigpoint)

end

