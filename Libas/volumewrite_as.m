function [] = volumewrite_as(sourcefilemat, funparameter)

% saves a sourceintpol file as an analyze img file (with hdr file)
% no scaling and by using the name of the original file
% filemat should be struct array 

% find funparamtername
dotindex = find(funparameter == '.');
funname = funparameter(dotindex+1:length(funparameter)) %#ok<NOPRT> %

for index = 1:size(sourcefilemat,1); 
   load(sourcefilemat(index).name, '-mat')

        cfgexp.scaling = 'no';
        cfgexp.parameter = funparameter;
        cfgexp.filename = [funname sourcefilemat(index).name];
        cfgexp.filetype = 'analyze';
        cfgexp.coordinates = 'spm';
        cfgexp.datatype = 'float';
        volumewrite(cfgexp, sourceIntPol)

end