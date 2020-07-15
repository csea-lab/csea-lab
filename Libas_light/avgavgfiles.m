function [] = avgavgfiles(inmat1, inmat2, outname); 

for index = 1:size(inmat1,1); 
    
     [AvgMat1,File,Path,FilePath,NTrialAvgVec,StdMat,SampRate,AvgRef,Version,MedMedRawVec,MedMedAvgVec,...
     EegMegStatus,NChanExtra,TrigPoint,HybridFactor,HybridDataCell,DataTypeVal]=ReadAvgFile(deblank(inmat1(index,:)));
 
    [AvgMat2,File,Path,FilePath,NTrialAvgVec,StdMat,SampRate,AvgRef,Version,MedMedRawVec,MedMedAvgVec,...
     EegMegStatus,NChanExtra,TrigPoint,HybridFactor,HybridDataCell,DataTypeVal]=ReadAvgFile(deblank(inmat2(index,:)));


     avgmat = ((AvgMat1)+(AvgMat2))./2; 

    
    SaveAvgFile([outname '.at' num2str(index)],avgmat,NTrialAvgVec,StdMat,SampRate,MedMedRawVec,MedMedAvgVec,...
EegMegStatus,NChanExtra,TrigPoint,HybridFactor,HybridDataCell,DataTypeVal);

end