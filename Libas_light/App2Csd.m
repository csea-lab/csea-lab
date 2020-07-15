function [CsdFileMat] = App2Csd(FileMat)
%	App2Csd
	
%   EMEGS - Electro Magneto Encephalography Software                           
%   © Copyright 2005 Markus Junghoefer & Peter Peyk                            
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
%   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
if nargin<2; Lambda=[]; end
if nargin<1; FileMat=[]; end

[NFiles,FileMat]=ReadFileNames(FileMat,'*.app*','Choose app. file(s) or batch file:');
if NFiles==0; CsdFileMat=[]; return; end
CsdFileMat=FileNameExt2Mat(FileMat,'.csd');
%==================================================================================
CoeffPathTmp=what('Emegs3dCoeff40'); % war Plot3dCoeff40!
CoeffPath=getfield(CoeffPathTmp,'path');
if strcmp(CoeffPath(length(CoeffPath)),filesep);CoeffPath=CoeffPath(1:length(CoeffPath)-1); end
LegPathTmp=what('Emegs3dLegCoeff'); % war Plot3dLegCoeff!
LegPath=getfield(LegPathTmp,'path');
if strcmp(LegPath(length(LegPath)),filesep); LegPath=LegPath(1:length(LegPath)-1); end
ECfgPathTmp=what('SensorCfg');
ECfgPath=getfield(ECfgPathTmp,'path');
if strcmp(ECfgPath(length(ECfgPath)),filesep); ECfgPath=ECfgPath(1:length(ECfgPath)-1); end
NChanOld=0;
for FileIndex=1:NFiles
	[File,Path,FilePath]=GetFileNameOfMat(FileMat,FileIndex);
	[CsdFile,CsdPath,CsdFilePath]=GetFileNameOfMat(CsdFileMat,FileIndex);
	[DataMat,Version,LHeader,ScaleBins,NChan,NPoints,NTrials,SampRate,AvgRefStatus]=ReadAppData(FilePath,0);
	%===========================================================================
	if NChan~=NChanOld
		ECfgFile=[int2str(NChan) '.ecfg'];
		ECfgFilePath=[ECfgPath,filesep,ECfgFile];
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
	for TrialInd=1:NTrials
		fprintf('File %g of %g; Trial %g of %g;\n',FileIndex,NFiles,TrialInd,NTrials);
		[DataMat,Version,LHeader,ScaleBins,NChan,NPoints,NTrials,SampRate,AvgRefStatus]=ReadAppData(FilePath,TrialInd);
		c0=mean(DataMat);
		DataMat=DataMat-(c0'*AllChanOnes)';
		DipStrength = InvCoeff \ DataMat;
		DataMat=(DipStrength' * CsdCoeff)';
		DataMat=DataMat+(c0'*AllChanOnes)';	
		fwrite(CsdFid,DataMat'.*ScaleBins,'float32');	%@@ ak was int16
	end
	fclose(CsdFid);
end
