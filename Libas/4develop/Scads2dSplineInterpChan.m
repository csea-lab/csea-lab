function OutMat = Scads2dSplineInterpChan(EEGMat, BadChanVec, ...
                                                                          EcfgFilePath, ScalpLambda);
% EEGMat should be channels (rows) by sample points (columns)
% BadChanVec should be vector of row indices to interpolate
% EcfgFilePath is string to .ecfg file
% Example function call: OutMat = Scads2dSplineInterpChan(EEGMat, [2,5,20], 'emegs2.8/emegs2dUtil/SensorCfg/HC1-257.ecfg');

% This code is dependent on EMEGS 2.8/emegs2dLib, will not run independently.
%
% Currently using Approx code status (ScalpCsdIndex = 1)


% Preparation path set up to load EEG configuration file and where to save
% coefficients. 
if(nargin <4)
    ScalpLambda = 0.0200;
end

CoeffPathTmp = what('emegs3dCoeff40');
CoeffPath = getfield(CoeffPathTmp,'path');
if strcmp(CoeffPath(length(CoeffPath)),filesep); CoeffPath = CoeffPath(1:length(CoeffPath)-1); end

LegPathTmp = what('emegs3dCoeff40');
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

%ECfgFile=EcfgFilePath;
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

fclose('all');
