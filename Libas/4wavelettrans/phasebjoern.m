% phasebjoern
% reads a text file line by line, digitizes it, writes it to mat, 
% performs wavelet transform; writes results to disk
% calculates phase-locking across time and channels
% evoke with e.g. [phaselockmat]=phasebjoern(mat, 210000, 4);
function []=phasebjoern(filemat);

% daten einlesen: wenn die daten noch nicht als matrix im workspace sind
% (zeitpunkte X sensoren), dann diese zeilen verwenden
% for lineindex = 1:NrSamples;
% newline = str2num(fgetl(fid));
% mat = [mat;newline];
% if lineindex/1000 == round(lineindex/1000), fprintf('.'), end
% end

freqRes = 1000/size(mat,1);
f0_start = 2/freqRes; % 2 Hz
f0_end = 45/freqRes; % 45 Hz

sigma_f = round((f0_end-f0_start)./30);

% wavelet generieren
disp('generate wavelet')
pause(.5)
[wavelet,cosine] = gener_wav_fast(size(mat,1), size(mat,1), sigma_f, f0_start, f0_end,7,100);
pause(.5)

% 3darray vorbereiten
%resmat = zeros(Nsensors,size(wavelet,1), size(wavelet,2));

% mit daten falten
disp('wavelet convolution with data')
for sensindex = 1:Nsensors;
tmp1(sensindex,:,:)=ifft(repmat(fft(mat(:,sensindex)' .* repmat(cosine,1,1),[],2),[1,1,size(wavelet,2)]) .*permute(repmat(wavelet,[1,1,1]),[3,1,2]),[],2);
disp(['sensor number: ' num2str(sensindex)])
end
save tmp1 tmp1 -mat

%optional zum anzeigen eines zeitfrequenzplots fuer eine unit; ggfs mit
%einem % wegkommentieren, denn es dauert ewig....
pcolor(squeeze(abs(tmp1(1,:,1:4:size(tmp1,3))))), shading interp;

clear wavelet
clear cosine

pause (.5)

disp('compute phaselocking')
% phaselocking
phaselockmat = [];
phaselockvec = [];
dummycount = 2;
for sens1 = 1 : Nsensors
    for sens2 = dummycount:Nsensors  
         for freq = 1:31;
            for index = 1:100:size(tmp1,2)-1000;  
                
                phaselock = sum(abs((tmp1(sens1,index:index+round(1000/(freq)),freq)./abs(tmp1(sens1,index:index+round(1000/(freq)),freq))) + ...
                 (tmp1(sens2,index:index+round(1000/(freq)),freq)./abs(tmp1(sens2,index:index+round(1000/(freq)),freq))))./2)./(round(1000/(freq))+1);
               
                phaselockvec = [phaselockvec phaselock];
            end
          
           phaselockmat = [phaselockmat;phaselockvec];
           phaselockvec = []; disp(['end freq' num2str(freq)]), disp(['size of matrix ' num2str(size(phaselockmat))]), 
         end
         disp(sens1)
         disp(sens2)
         phaselockmat = movavg(phaselockmat,15);
         eval(['save phaselockmat' num2str(sens1) '_' num2str(sens2) ' phaselockmat -mat'])
         % optional:
         surf(phaselockmat)
         
         phaselockmat = []; 
        
    end
    dummycount = dummycount + 1;
end



