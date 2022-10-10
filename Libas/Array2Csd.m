function [CSDarray] = Array2Csd(array, Lambda, ECfgFile)
%	
%   modified from app2csd AK2013
%   assumes 3-D array with elec by time by trials 
%   This program is distributed in the hope that it will be useful,            
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              
%   GNU General Public License for more details.
%   
%   You should have received a copy of the GNU General Public License          
%   along with this program; if not, write to the Free Software                
%   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
if nargin<2; Lambda=[]; end
if nargin<1; FileMat=[]; end

NChan = size(array,1); 
CSDarray = zeros(size(array)); 
%==================================================================================
CoeffPathTmp=what('emegs3dCoeff40');
CoeffPath=getfield(CoeffPathTmp,'path');
if strcmp(CoeffPath(length(CoeffPath)),filesep);CoeffPath=CoeffPath(1:length(CoeffPath)-1); end
LegPathTmp=what('emegs3dLegCoeff');
LegPath=getfield(LegPathTmp,'path');
if strcmp(LegPath(length(LegPath)),filesep); LegPath=LegPath(1:length(LegPath)-1); end
ECfgPathTmp=what('SensorCfg');
ECfgPath=getfield(ECfgPathTmp,'path');
if strcmp(ECfgPath(length(ECfgPath)),filesep); ECfgPath=ECfgPath(1:length(ECfgPath)-1); end
NChanOld=0;

	%===========================================================================
	if NChan~=NChanOld
		%ECfgFile=[int2str(NChan) '.ecfg'];
		ECfgFilePath=[ECfgPath,filesep,ECfgFile];
		fid=fopen(ECfgFilePath,'r','b');
		fprintf('Start reading sensor configuration...\n\n');
		fprintf(ECfgFilePath),
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
        
        for trial = 1:size(array,3)

            trialdata = squeeze(array(:, :, trial)); 

            c0=mean(trialdata);
            DataMat=trialdata-(c0'*AllChanOnes)';
            DipStrength = InvCoeff \ DataMat;
            DataMat=(DipStrength' * CsdCoeff)';
            DataMat=DataMat+(c0'*AllChanOnes)';	

            CSDarray(:, :, trial) = DataMat; 
        end
        
		
	end


