fclose('all')
%RAWFilePath = 'c1p1_312_20220417_125138.RAW'
% RAWFilePath = 'nat_sounds_M605.RAW'
RAWFilePath = 'fomcon335.RAW'

RAWFid=fopen(RAWFilePath,'r','b');


fseek(RAWFid,22,-1);
NChan=fread(RAWFid,1,'short')
Gain=fread(RAWFid,1,'short')
Bits=fread(RAWFid,1,'short')

FormatStr='float32';
Bytes = 8

Range=fread(RAWFid,1,'short');
NPoints=fread(RAWFid,1,'long')
NEvents=fread(RAWFid,1,'short')
NTotChan=NChan+NEvents

fseek(RAWFid,NEvents.*4,0);

LHeader=ftell(RAWFid)
LRawFile=LHeader+NTotChan.*NPoints.*Bytes
fseek(RAWFid,0,-1);
Header=[];
Header=fread(RAWFid,LHeader,'int8')

fseek(RAWFid,LHeader,-1);
DataMat=fread(RAWFid,[NTotChan,10000],FormatStr);
DataMat = bslcorr(DataMat,1:100); 
figure, 
plot(DataMat(256,1:1000))