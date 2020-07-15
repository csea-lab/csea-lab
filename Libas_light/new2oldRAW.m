% new2oldRAW
function [DataMat] = new2oldRAW(RAWFilePath); 

RAWFid=fopen(RAWFilePath,'r','b');
oldformatRAWFid=fopen(['old' RAWFilePath],'w','b');

	fseek(RAWFid,22,-1);
		NChan=fread(RAWFid,1,'short')
		Gain=fread(RAWFid,1,'short')
        Bits=fread(RAWFid,1,'short')
        if Bits==0
            Bytes=4;
            FormatStr='float32';
         elseif Bits == 12  % added by AK august 2012
             Bits = 24
             Bytes=4;
             FormatStr='float32';
        else
            Bytes=2;
            FormatStr='int16';
        end
        fprintf(1,['Data given in ',FormatStr,' format.\n']);
        
        Range=fread(RAWFid,1,'short')
		NPoints=fread(RAWFid,1,'long')
		NEvents=fread(RAWFid,1,'short')
		NTotChan=NChan+NEvents
		fseek(RAWFid,NEvents.*4,0);
		LHeader=ftell(RAWFid)
        LRawFile=LHeader+NTotChan.*NPoints.*Bytes
		fseek(RAWFid,0,-1);
		Header=[];
		Header=fread(RAWFid,LHeader,'int8')
        
        Header(27:28) = [0 16]
        
        
		fwrite(oldformatRAWFid,Header,'int8');	
        
         [DataMat,Count]=fread(RAWFid,[NTotChan,NPoints],FormatStr); 
              figure(1), plot(bslcorr(DataMat, 1:100)') % remove @
			Count=fwrite(oldformatRAWFid,DataMat,'int16');
