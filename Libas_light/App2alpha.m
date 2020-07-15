function [CsdFileMat] = App2alpha(FileMat)
%	App2Csd	
%   EMEGS - Electro Magneto Encephalography Software                           
%   ? Copyright 2005 Markus Junghoefer & Peter Peyk                            
%   Implemented programs from: Andrea de Cesarei, Thomas Gruber,               
%   Olaf Hauk, Andreas Keil, Olaf Steinstraeter, Nathan Weisz                  
%   and Andreas Wollbrink.                                                     
%                                                                              
%   This program is free software; you can redistribute it and/or              
%   modify it under the terms of the GNU General Public License                
%   as published by the Free Software Foundation; either version 3             
%   of the License, or (at your option) any later version.                     
%                                                                              
%   This program is distributed in the hope that it will be useful,            
%   but WITHOUT ANY WARRANTY; without even the implied warranty of             
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              
%   GNU General Public License for more details.                               
%   You should have received a copy of the GNU General Public License          
%   along with this program; if not, write to the Free Software                
%   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307,
%   USA.
if nargin<2; Lambda=2; end
if nargin<1; FileMat=[]; end



[NFiles,FileMat]=ReadFileNames(FileMat,'*.app*','Choose app. file(s) or batch file:');
if NFiles==0; CsdFileMat=[]; return; end
CsdFileMat=FileNameExt2Mat(FileMat,'.alph');
%==================================================================================
CoeffPathTmp=what('emegs3dCoeff40');
CoeffPath=getfield(CoeffPathTmp,'path');
if strcmp(CoeffPath(length(CoeffPath)),FileSep);CoeffPath=CoeffPath(1:length(CoeffPath)-1); end
LegPathTmp=what('emegs3dLegCoeff');
LegPath=getfield(LegPathTmp,'path');
if strcmp(LegPath(length(LegPath)),FileSep); LegPath=LegPath(1:length(LegPath)-1); end
ECfgPathTmp=what('SensorCfg');
ECfgPath=getfield(ECfgPathTmp,'path');
if strcmp(ECfgPath(length(ECfgPath)),FileSep); ECfgPath=ECfgPath(1:length(ECfgPath)-1); end
NChanOld=0;
for FileIndex=1:NFiles
    fclose('all')
	[File,Path,FilePath]=GetFileNameOfMat(FileMat,FileIndex);
	[CsdFile,CsdPath,CsdFilePath]=GetFileNameOfMat(CsdFileMat,FileIndex);
	[DataMat,Version,LHeader,ScaleBins,NChan,NPoints,NTrials,SampRate,AvgRefStatus]=ReadAppData(FilePath,0);
	%===========================================================================
	if NChan~=NChanOld
		ECfgFile=[int2str(NChan) '.ecfg'];
		ECfgFilePath=[ECfgPath,FileSep,ECfgFile];
		fid=fopen(ECfgFilePath,'r','b');
		fprintf('Start reading sensor configuration...\n\n');
		fprintf(ECfgFilePath)
		fprintf('\n\n');
		NChan=fread(fid,1,'int16');	
		ScalpRadius=fread(fid,1,'float32');
		TmpSpher=fread(fid,[NChan,2],'float32');
		fclose(fid);
		AllEPosSpher=zeros(NChan,3);
		AllEPosSpher(:,1:2)=TmpSpher(1:NChan,:);
		AllEPosSpher(:,3)=ScalpRadius.*ones(NChan,1);
		AllEPosCart = change_sphere_cart(AllEPosSpher,ScalpRadius,1);
		[InvCoeff] = ReadOrCalcCoeff(1,AllEPosCart,AllEPosCart,LegPath,CoeffPath,ECfgFile,32,15, 0, 5001);	
		[CsdCoeff] = ReadOrCalcCoeff(3,AllEPosCart,AllEPosCart,LegPath,CoeffPath,ECfgFile,NChan,15, 0, 5001);
		[Lambda]=IfEmptyInputValInt('Insert lambda value of approximation:','(zero ~ no approximation)',Lambda,2,0,100,1);
		InvCoeff=InvCoeff+Lambda.*InvCoeff(1,1).*eye(NChan);
		AllChanOnes=ones(1,NChan);
		NChanOld=NChan;
	end	
	%===========================================================================
	CsdFid=fopen(CsdFilePath,'w','b');
	fwrite(CsdFid,Version,'int16');
	fwrite(CsdFid,LHeader,'int16');
	fwrite(CsdFid,ScaleBins,'int16');
	fwrite(CsdFid,NChan,'int16');
	fwrite(CsdFid,NPoints,'int16');
	fwrite(CsdFid,NTrials,'int16');
	fwrite(CsdFid,SampRate,'int16');
	fwrite(CsdFid,AvgRefStatus,'int16');	
	ZeroVec=zeros(LHeader-16,1);
	fwrite(CsdFid,ZeroVec,'int8');	
    % testsig
    t = 0:0.004:6; 
   
	for TrialInd=1:NTrials
         
        onsetvec = randperm (300); 
        onset = onsetvec(1)+650;
        freqvec = randperm(40); 
        freqja = 8.9+ freqvec(1)./11;
        sig = sin(2*pi*t*freqja); 
        size(sig);
       
		fprintf('.');
		[DataMat,Version,LHeader,ScaleBins,NChan,NPoints,NTrials,SampRate,AvgRefStatus]=ReadAppData(FilePath, TrialInd);
       % data2 = fliplr(DataMat);
        data2 = DataMat;
        size(data2([108:111 100 116:129 137:141 148:153 158:161 168 99 130 87 143],onset:onset+1500));
		data2([108:111 100 116:129 137:141 148:153 158:161 168 99 130 87 143],onset:onset+1500) = DataMat([108:111 100 116:129 137:141 148:153 158:161 168 99 130 87 143], onset:onset+1500 ) + repmat(sig, 39,1).*3.1; 
        %plot(data2'), pause(.2)  
		fwrite(CsdFid,data2'.*ScaleBins,'float32');	
	end
	fclose(CsdFid);
    fclose('all'); 
end
