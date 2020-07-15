function [] = avgstrucWA(filemat, outname); 

if isstruct(filemat)

else

for index = 1:size(filemat,1); 
    
    a = load (deblank(filemat(index,:))); 
    
    if index == 1; 
    summat = a.WaData.WaPower;
    else
    summat = a.WaData.WaPower + summat;
    end
    
end




end %else strucarray


WaData.WaPower = summat./size(filemat,1); 

WaData.tAxis = a.WaData.tAxis;
WaData.fAxis = a.WaData.fAxis;

save(outname, 'WaData'); 

    
    