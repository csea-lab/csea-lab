function OutMat = Scads2dSplineInterpChan(EEGMat, BadChanVec, ...
                                                                          EcfgFilePath, ScalpLambda);
% EEGMat should be channels (rows) by sample points (columns)
% BadChanVec should be vector of row indices to interpolate
% EcfgFilePath is string to .ecfg file
% Example function call: OutMat = Scads2dSplineInterpChan(EEGMat, [2,5,20], 'emegs2.8/emegs2dUtil/SensorCfg/HC1-257.ecfg');

% This code is highly dependent on EMEGS 2.8, will not run independently.
% Does this need more error checking for like number of sensors?
% Currently using Approx code status (ScalpCsdIndex = 1), not CSD or anything else


% Preperation path set up to load EEG configuration file and where to save
% coefficients. 
if(nargin <4)
    ScalpLambda = 0.0200;
end

CoeffPathTmp = what('emegs3dCoeff40');
CoeffPath = getfield(CoeffPathTmp,'path');
if strcmp(CoeffPath(length(CoeffPath)),filesep); CoeffPath = CoeffPath(1:length(CoeffPath)-1); end

LegPathTmp = what('emegs3dLegCoeff');
LegPath = getfield(LegPathTmp,'path');
if strcmp(LegPath(length(LegPath)),filesep); LegPath = LegPath(1:length(LegPath)-1); end

% Prepare necessary information
if (~endsWith(EcfgFilePath, '.ecfg'))
    EcfgFilePath = [EcfgFilePath '.ecfg'];
end

if ~(exist(EcfgFilePath) == 2)
    error('EcfgFilePath does not point a real .ecfg EEG configuration file')
end

EcfgFid = fopen(EcfgFilePath,'r','b');

[NChanCalc,count] = fread(EcfgFid,1,'int16');	
[ScalpRadius,count] = fread(EcfgFid,1,'float32');
[TmpSpher,count]= fread(EcfgFid,[NChanCalc,2],'float32');

fclose(EcfgFid);

AllEPosSpher=zeros(NChanCalc,3);
AllEPosSpher(:,1:2)=TmpSpher(1:NChanCalc,:);
AllEPosSpher(:,3)=ScalpRadius.*ones(NChanCalc,1);
AllEPosCart = change_sphere_cart(AllEPosSpher,ScalpRadius,1);

ECfgFile=GetDefEcfgFile(NChanCalc);

NPoints = size(EEGMat,2);

GoodChannelsTrueFalseVec = true(NChanCalc,1);
GoodChannelsTrueFalseVec([BadChanVec]) = false;

NGoodChan = sum(GoodChannelsTrueFalseVec);

Channels = 1:NChanCalc;
GoodChanVec = Channels(GoodChannelsTrueFalseVec);

% Calc InvCoeff
[InvCoeff] = ReadOrCalcCoeff(1,AllEPosCart,AllEPosCart,LegPath, ...
                                                  CoeffPath,ECfgFile,32,15, 0, 5001,[],[],0);



%Calculate Lambda and ForCoeff
Lambda=ScalpLambda.*InvCoeff(1,1);
ForCoeff=InvCoeff';


% Recalculate InvCoeff, recalc, change diagnonal for some reason
InvCoeff=InvCoeff+Lambda.*eye(NChanCalc);

AllChanOnes=ones(1,NChanCalc);
OutMat=zeros(NChanCalc,NPoints);

% Apply spline
TmpEEGMat=EEGMat(GoodChanVec,:);
c0=mean(TmpEEGMat);
TmpEEGMat=TmpEEGMat-(c0'*ones(1,NGoodChan))';
DipStrength = InvCoeff(GoodChanVec,GoodChanVec) \ TmpEEGMat;
TmpEEGMat=(DipStrength' * ForCoeff(GoodChanVec,:))';
TmpEEGMat=TmpEEGMat+(c0'*AllChanOnes)';
EEGMat(BadChanVec,:)=TmpEEGMat(BadChanVec,:);

OutMat(1:NChanCalc,:)=OutMat(1:NChanCalc,:)+EEGMat;




% CoeffPathTmp=what('csea3dCoeff40');
% CoeffPath=getfield(CoeffPathTmp,'path');
% if strcmp(CoeffPath(length(CoeffPath)),filesep);CoeffPath=CoeffPath(1:length(CoeffPath)-1); end
% LegPathTmp=what('csea3dLegCoeff');
% LegPath=getfield(LegPathTmp,'path');
% if strcmp(LegPath(length(LegPath)),filesep); LegPath=LegPath(1:length(LegPath)-1); end
% ECfgPathTmp=what('SensorCfg');
% ECfgPath=getfield(ECfgPathTmp,'path');
% if strcmp(ECfgPath(length(ECfgPath)),filesep); ECfgPath=ECfgPath(1:length(ECfgPath)-1); end



% 
% 
% 
% 
% 
%
% % from line 171 EmegsAvgRunAverage.m
% 
% 
% 
% 
% EcfgFid = fopen(EcfgFilePath,'r','b');
% 
% [NChanCalc,count] = fread(EcfgFid,1,'int16');	
% [ScalpRadius,count] = fread(EcfgFid,1,'float32');
% [TmpSpher,count]= fread(EcfgFid,[NChanCalc,2],'float32');
% 
% fclose(EcfgFid);
% 
% AllEPosSpher=zeros(NChanCalc,3);
% AllEPosSpher(:,1:2)=TmpSpher(1:NChanCalc,:);
% AllEPosSpher(:,3)=ScalpRadius.*ones(NChanCalc,1);
% AllEPosCart = change_sphere_cart(AllEPosSpher,ScalpRadius,1);
% % Calculate spline coefficients 
% [InvCoeff] = ReadOrCalcCoeff(1,AllEPosCart,AllEPosCart,LegPath,CoeffPath,ECfgFile,32,15, 0, 5001,[],[],0);
% InvCoeffBackup = InvCoeff;
% [CsdCoeff] = ReadOrCalcCoeff(3,AllEPosCart,AllEPosCart,LegPath,CoeffPath,ECfgFile,NChanCalc,15,0,5001,[],[],0);
% 
% 
% 
% if UseApproxStatus
% 	fid=fopen(ECfgFilePath,'r','b');
%     if ~get(hAvgList(88),'userdata')
% 	    fprintf('Start reading of file...\n\n');
% 	    disp(ECfgFilePath)
% 	    fprintf('\n\n');
%     end
% 	[NChanCalc,count] = fread(fid,1,'int16');	
% 	[ScalpRadius,count] = fread(fid,1,'float32');
% 	[TmpSpher,count]= fread(fid,[NChanCalc,2],'float32');
% 	fclose(fid);
% 	AllEPosSpher=zeros(NChanCalc,3);
% 	AllEPosSpher(:,1:2)=TmpSpher(1:NChanCalc,:);
% 	AllEPosSpher(:,3)=ScalpRadius.*ones(NChanCalc,1);
% 	AllEPosCart = change_sphere_cart(AllEPosSpher,ScalpRadius,1);
% 	[InvCoeff] = ReadOrCalcCoeff(1,AllEPosCart,AllEPosCart,LegPath,CoeffPath,ECfgFile,32,15, 0, 5001,[],[],0);
%     InvCoeffBackup = InvCoeff;
% 	[CsdCoeff] = ReadOrCalcCoeff(3,AllEPosCart,AllEPosCart,LegPath,CoeffPath,ECfgFile,NChanCalc,15,0,5001,[],[],0);
% else
% 
%     InvCoeffBackup=[];
% end
% % taken from EmegsAvgRunAverage.m line 740
% 	for ScalpCsdIndex=StartIndex:EndIndex
% 		if ScalpCsdIndex==1		%Scalp
% 			if UseApproxStatus
% 				Lambda=ScalpLambda.*InvCoeff(1,1);
% 				ForCoeff=InvCoeff';
% 			end
% 			ScaleBins=ScalpScaleBins;
% 			SaveSCADSStatus=SaveScalpSCADSStatus;
% 			SaveEGISStatus=SaveScalpEGISStatus;
% 			SaveAppStatus=SaveScalpAppStatus;
% 			SaveIndStatus=SaveScalpIndStatus;
% 			set(AvgInfoFig,'Name','Average Scalp Potential Info:');
% 		elseif ScalpCsdIndex==2	%Csd
% 			if UseApproxStatus
% 				Lambda=CsdLambda.*InvCoeff(1,1);
% 				ForCoeff=CsdCoeff;
% 			end
% 			ScaleBins=CsdScaleBins;	
% 			SaveSCADSStatus=SaveCsdSCADSStatus;
% 			SaveEGISStatus=SaveCsdEGISStatus;
% 			SaveAppStatus=SaveCsdAppStatus;
% 			SaveIndStatus=SaveCsdIndStatus;
% 			set(AvgInfoFig,'Name','Average CSD Info:');
% 		end
% 
% % taken from EmegsAvgRunAverage.m line 883
% 			if UseApproxStatus
% 				InvCoeff=InvCoeff+Lambda.*eye(NChanCalc);				
% 				TmpDataMat=zeros(NChanCalc,NPoints);
% 				if SesFileFormatVal==1 | SesFileFormatVal==2 | SesFileFormatVal==5
% 					OrigDataFid=fopen(DataFilePath,'r','b');
% 					Header=fread(OrigDataFid,LHeader,'int8');
% 					fclose(OrigDataFid);
% 				end
% 			end
% 			AvgMat=zeros(NChanCalc+NChanExtra,NPoints);
% 			DataMat=zeros(NChanCalc,NPoints);
% 
% 
% 
% 
% 
%             % Filling in channels
% % taken from EmegsAvgRunAverage.m line 1102
%             if ScalpCsdIndex==1
%                 if UseApproxStatus
%                     if ~isempty(BadChanVec)
%                         TmpDataMat=DataMat(GoodChanVec,:);
%                         c0=mean(TmpDataMat);
%                         TmpDataMat=TmpDataMat-(c0'*ones(1,NGoodChan))';
%                         DipStrength = InvCoeff(GoodChanVec,GoodChanVec) \ TmpDataMat;
%                         TmpDataMat=(DipStrength' * ForCoeff(GoodChanVec,:))';
%                         TmpDataMat=TmpDataMat+(c0'*AllChanOnes)';
%                         DataMat(BadChanVec,:)=TmpDataMat(BadChanVec,:);
%                     end
%                     MedMedRawVec(TrialInd)=median(median(abs(DataMat(:,TimeIndVec))));
%                     AvgMat(1:NChanCalc,:)=AvgMat(1:NChanCalc,:)+DataMat;
%                 else
%                     MedMedRawVec(TrialInd)=median(median(abs(DataMat(GoodChanVec,TimeIndVec))));
%                     AvgMat(GoodChanVec,:)=AvgMat(GoodChanVec,:)+DataMat(GoodChanVec,:);
%                 end
%             elseif ScalpCsdIndex==2
%                 TmpDataMat=DataMat(GoodChanVec,:);
%                 c0=mean(TmpDataMat);
%                 TmpDataMat=TmpDataMat-(c0'*ones(1,NGoodChan))';
%                 DipStrength = InvCoeff(GoodChanVec,GoodChanVec) \ TmpDataMat;
%                 TmpDataMat=(DipStrength' * ForCoeff(GoodChanVec,:))';
%                 DataMat=TmpDataMat+(c0'*AllChanOnes)';
%                 MedMedRawVec(TrialInd)=median(median(abs(DataMat)));
%                 AvgMat=AvgMat+DataMat;
%             end
% 
% end