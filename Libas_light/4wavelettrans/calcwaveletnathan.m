% phasebjoern
% reads a text file line by line, digitizes it, writes it to mat, 
% performs wavelet transform; writes results to disk
% calculates phase-locking across time and channels
% evoke with e.g. [phaselockmat]=phasebjoern(mat, 210000, 4);
%function [phaselockmat,f]=calacwaveletnathan(mat, NrSamples, NPointsNew,NPointsOld,flow,fhigh);
function [PowMat,RayPMat,RayBarMat,f]=calcwaveletnathan(mat,flower,fhigh,FS,pathout,filebase);

% daten einlesen: wenn die daten noch nicht als matrix im workspace sind
% (zeitpunkte X sensoren), dann diese zeilen verwenden
% for lineindex = 1:NrSamples;
% newline = str2num(fgetl(fid));
% mat = [mat;newline];
% if lineindex/1000 == round(lineindex/1000), fprintf('.'), end
% end
%27.2.06 (nw): now assumes mat to be 3-dimensional (e.g. EEG.data; elec x points x trials)
%               computes phase locking using the PhasePack Toolbox
%               (http://www.vis.caltech.edu/~rizzuto/phasepack/)
%               if pathout and filebase (e.g. subject name) are specified, then complex values
%               of single trials are saved as mats (trials x points x freq)

Nsensors=size(mat,1);
NPointsOld=size(mat,2);
NPointsNew=2^nextpow2(NPointsOld);

%%%VON UNTEN HOCH ... wichtig da punkte zahl nach zero-padding
%%%frequenzauflšsung beeinflusst
trials=size(mat,3);

mat = [mat, zeros(Nsensors,NPointsNew-NPointsOld,trials)];

%freqRes = 1000/size(mat,1);
freqRes = FS/size(mat,2);
f0_start = flower/freqRes; % 2 Hz
f0_end = fhigh/freqRes; % 45 Hz

sigma_f = round((f0_end-f0_start)./60); %mit nenner ist frequenzauflösung modulierbar
%sigma_f gibt hier an jedes wievielte wavelet benutzt werden soll
%("Auslassungswert")

f=freqRes*f0_start:freqRes*sigma_f:freqRes*f0_end;

% %%%EVT HIER AUSLASSEN
% trials=size(mat,3);
% 
% %zero padding --> mit andreas verifizieren ob notwendig
% mat = [mat, zeros(Nsensors,NPointsNew-NPointsOld,trials)];

% wavelet generieren
disp('generate wavelet')

%[wavelet,cosine] = gener_wav_fast(size(mat,1), size(mat,1), sigma_f, f0_start, f0_end,7,100);
[wavelet,cosine] = gener_wav_fast(NPointsNew, NPointsOld, sigma_f, f0_start, f0_end,7,10);


% mit daten falten

disp('wavelet convolution with data')
for sensnum = 1:Nsensors
     tmpmat=squeeze(mat(sensnum,:,:));
    %for sensindex = 1:Nsensors; %hier eigentlich trials
    for trialind = 1:trials
        tmp1(trialind,:,:)=ifft(repmat(fft(tmpmat(:,trialind)' .* repmat(cosine,1,1),[],2),[1,1,size(wavelet,2)]) .*permute(repmat(wavelet,[1,1,1]),[3,1,2]),[],2);
        disp(['trial number: ' num2str(trialind)])
        
    end%trialind 
    PowMat(:,:,sensnum)=squeeze(double(mean(abs(tmp1),1))).^2;
    
    for freqind=1:length(f)
        for pointind=1:NPointsOld
            [RayPMat(pointind,freqind,sensnum),RayBarMat(pointind,freqind,sensnum)]=rayleigh(angle(tmp1(:,pointind,freqind)));
        end%pointind
    end% freqind
    
    if nargin >5
        file=[pathout filebase '_cp_chan' num2str(sensnum) '.mat']
        cp = tmp1(:,1:NPointsOld,:);
        eval(['save ' file ' cp'])
    end %if
    
    %noch option einbauen um komplexe zahlen zu speichern als mat (nachher
    %verwenden für phasen bi-coherence)
end % sensnum

PowMat=PowMat(1:NPointsOld,:,:);

% divvec=squeeze(mean(PowMat(1:100,:,:),1));
% 
% for i = 1:3
%     for k = 1:30
%         tmpdiv(:,k,i)=PowMat(:,k,i)/divvec(k,i);
%     end
% end

